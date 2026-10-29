(function (window, document) {
    'use strict';

    var RealtimeSync = {
        config: {
            role: 'client',
            userId: 0,
            ctx: '',
            wsUrl: '',
            pollInterval: 1500,
            soundEnabled: true
        },
        state: {
            socket: null,
            isConnected: false,
            pollTimer: null,
            lastEventId: 0,
            handledEvents: new Set(),
            audioCtx: null,
            channel: null
        },

        init: function (options) {
            this.config = Object.assign(this.config, options || {});
            this.state.lastEventId = Date.now();

            this.initAudioContext();
            this.initBroadcastChannel();
            this.initToaster();
            this.connectWebSocket();

            var unlockAudio = function () {
                if (RealtimeSync.state.audioCtx && RealtimeSync.state.audioCtx.state === 'suspended') {
                    RealtimeSync.state.audioCtx.resume();
                }
                document.removeEventListener('click', unlockAudio);
                document.removeEventListener('keydown', unlockAudio);
            };
            document.addEventListener('click', unlockAudio);
            document.addEventListener('keydown', unlockAudio);

            console.log('[RealtimeSync] Khởi tạo thành công với vai trò: ' + this.config.role + ' (UserId: ' + this.config.userId + ')');
        },

        connectWebSocket: function () {
            var self = this;
            var loc = window.location;
            var proto = loc.protocol === 'https:' ? 'wss:' : 'ws:';
            var defaultWsUrl = proto + '//' + loc.host + self.config.ctx + '/ws/realtime?role=' + encodeURIComponent(self.config.role) + '&userId=' + self.config.userId;
            var wsUrl = self.config.wsUrl || defaultWsUrl;

            try {
                var ws = new WebSocket(wsUrl);

                ws.onopen = function () {
                    self.state.isConnected = true;
                    self.stopPolling();
                    console.log('[RealtimeSync] WebSocket ĐÃ KẾT NỐI THÀNH CÔNG tới ' + wsUrl);

                    self.updateConnectionIndicator(true);

                    if (self._heartbeat) clearInterval(self._heartbeat);
                    self._heartbeat = setInterval(function () {
                        if (ws.readyState === WebSocket.OPEN) {
                            ws.send('ping');
                        }
                    }, 20000);
                };

                ws.onmessage = function (event) {
                    if (event.data === 'pong') return;
                    try {
                        var ev = JSON.parse(event.data);
                        if (ev && ev.type && ev.type !== 'CONNECTED') {
                            self.dispatchIncomingEvent(ev, 'websocket');
                        }
                    } catch (err) {
                        console.error('[RealtimeSync] Lỗi phân tích sự kiện WS:', err, event.data);
                    }
                };

                ws.onerror = function (err) {
                    console.warn('[RealtimeSync] WebSocket gặp sự cố, kích hoạt Fallback Polling...', err);
                    self.state.isConnected = false;
                    self.startPolling();
                };

                ws.onclose = function () {
                    self.state.isConnected = false;
                    self.updateConnectionIndicator(false);
                    if (self._heartbeat) clearInterval(self._heartbeat);

                    console.warn('[RealtimeSync] WebSocket bị ngắt, thử kết nối lại sau 2.5s...');
                    self.startPolling();
                    setTimeout(function () {
                        self.connectWebSocket();
                    }, 2500);
                };

                self.state.socket = ws;
            } catch (e) {
                console.warn('[RealtimeSync] Trình duyệt không thể tạo WebSocket:', e);
                self.startPolling();
            }
        },

        startPolling: function () {
            var self = this;
            if (self.state.pollTimer) return;
            console.log('[RealtimeSync] Bắt đầu Fallback Polling chu kỳ ' + self.config.pollInterval + 'ms');

            self.state.pollTimer = setInterval(function () {
                var url = self.config.ctx + '/api/realtime-sync?sinceId=' + self.state.lastEventId
                    + '&role=' + encodeURIComponent(self.config.role)
                    + '&userId=' + self.config.userId;

                fetch(url, { cache: 'no-store' })
                    .then(function (res) { return res.json(); })
                    .then(function (events) {
                        if (Array.isArray(events) && events.length > 0) {
                            events.forEach(function (ev) {
                                self.dispatchIncomingEvent(ev, 'poll');
                            });
                        }
                    })
                    .catch(function () {});
            }, self.config.pollInterval);
        },

        stopPolling: function () {
            if (this.state.pollTimer) {
                clearInterval(this.state.pollTimer);
                this.state.pollTimer = null;
                console.log('[RealtimeSync] Đã dừng Fallback Polling vì WebSocket đã hoạt động!');
            }
        },

        initBroadcastChannel: function () {
            var self = this;
            if (typeof BroadcastChannel !== 'undefined') {
                try {
                    self.state.channel = new BroadcastChannel('dopc_realtime_channel');
                    self.state.channel.onmessage = function (e) {
                        if (e.data && e.data.type) {
                            self.dispatchIncomingEvent(e.data, 'broadcast_channel');
                        }
                    };
                } catch (err) {}
            }
        },

        dispatchIncomingEvent: function (ev, source) {
            if (!ev || !ev.id) return;

            if (this.state.handledEvents.has(ev.id)) return;
            this.state.handledEvents.add(ev.id);
            if (ev.id > this.state.lastEventId) {
                this.state.lastEventId = ev.id;
            }

            if (source !== 'broadcast_channel' && this.state.channel) {
                try {
                    this.state.channel.postMessage(ev);
                } catch (ignored) {}
            }

            console.log('[RealtimeSync] NHẬN SỰ KIỆN [' + ev.type + ']:', ev);

            if (this.config.soundEnabled) {
                this.playAudioChime(ev.soundType || 'info');
            }

            this.showToast(ev);

            this.applyDomUpdates(ev);

            if (typeof window.updateProfitChart === 'function') {
                try {
                    window.updateProfitChart(ev);
                } catch (chartErr) {
                    console.error('[RealtimeSync] Lỗi updateProfitChart:', chartErr);
                }
            }
        },

        applyDomUpdates: function (ev) {
            var type = ev.type;
            var data = ev.data || {};
            var self = this;

            if (type === 'ORDER_CREATED') {

                var ordersTable = document.querySelector('.table.tbl tbody') || document.querySelector('#ordersTable tbody');
                if (ordersTable && self.config.role === 'admin') {
                    var orderId = data.orderId;
                    var moneyFmt = data.totalMoneyFormatted || (Number(data.totalMoney).toLocaleString('vi-VN') + ' đ');
                    var payBadge = data.paymentMethod === 'QR'
                        ? '<span class="badge bg-info text-dark">QR</span><div class="mt-1"><span class="badge bg-danger">Chưa thanh toán</span></div>'
                        : '<span class="badge bg-secondary">COD</span>';

                    var discountHtml = '';
                    if (data.discountAmount > 0) {
                        discountHtml = '<div class="small text-success fw-normal" style="font-size: 11px;"><i class="fa-solid fa-ticket me-1"></i>-'
                            + Number(data.discountAmount).toLocaleString('vi-VN') + ' đ</div>';
                    }

                    var newRow = document.createElement('tr');
                    newRow.id = 'order-row-' + orderId;
                    newRow.setAttribute('data-order-id', orderId);
                    newRow.className = 'realtime-pulse-green';
                    newRow.innerHTML = ''
                        + '<td class="fw-bold"><span class="badge bg-danger me-1">MỚI</span>#' + orderId + '</td>'
                        + '<td><div class="prod-name fw-bold text-danger">' + self.escapeHtml(data.receiverName) + '</div>'
                        + '<div class="muted" style="font-size: 13px;">' + self.escapeHtml(data.email) + '</div></td>'
                        + '<td class="price"><div>' + moneyFmt + '</div>' + discountHtml + '</td>'
                        + '<td>' + payBadge + '</td>'
                        + '<td><span class="badge bg-warning text-dark"><i class="fa-solid fa-clock me-1"></i>Chờ xử lý</span></td>'
                        + '<td class="text-end">'
                        + '<a href="' + self.config.ctx + '/admin/orders?id=' + orderId + '" class="btn btn-sm btn-danger px-3 shadow-sm">Xem ngay</a>'
                        + '</td>';

                    ordersTable.insertBefore(newRow, ordersTable.firstChild);

                    var emptyRow = ordersTable.querySelector('td.muted');
                    if (emptyRow) emptyRow.closest('tr').remove();
                }

                var totalOrdersElem = document.querySelector('#kpi-total-orders') || document.querySelector('.stat-card:nth-child(2) .fs-4');
                if (totalOrdersElem && self.config.role === 'admin') {
                    var currentOrders = parseInt(totalOrdersElem.textContent.replace(/\D/g, '')) || 0;
                    totalOrdersElem.textContent = (currentOrders + 1) + ' đơn';
                    totalOrdersElem.classList.add('realtime-text-flash');
                    setTimeout(function () { totalOrdersElem.classList.remove('realtime-text-flash'); }, 2000);
                }
            }

            if (type === 'ORDER_CANCELLED') {
                var orderId = data.orderId;

                var row = document.getElementById('order-row-' + orderId) || document.querySelector('[data-order-id="' + orderId + '"]');
                if (row) {
                    var statusCell = row.cells && row.cells[4] ? row.cells[4] : row.querySelector('.badge');
                    if (statusCell) {
                        statusCell.innerHTML = '<span class="badge bg-danger"><i class="fa-solid fa-ban me-1"></i>Khách hủy đơn</span>';
                    }
                    row.classList.add('realtime-pulse-red');
                    setTimeout(function () { row.classList.remove('realtime-pulse-red'); }, 3000);
                }
            }

            if (type === 'ORDER_STATUS_CHANGED') {
                var orderId = data.orderId;
                var newStatus = data.newStatus;
                var newStatusName = data.statusDisplayName || newStatus;

                var currentUrl = window.location.href;
                if (currentUrl.indexOf('order-detail') !== -1 && currentUrl.indexOf('id=' + orderId) !== -1) {

                    var badgeContainer = document.querySelector('#order-detail-status-badge') || document.querySelector('.od-wrap .d-flex .badge');
                    if (badgeContainer) {
                        badgeContainer.textContent = newStatusName;
                        badgeContainer.className = 'badge fs-6 px-3 py-2 text-white ' + self.getStatusBadgeClass(newStatus);
                    }

                    var cancelBtn = document.querySelector('form[action*="order-action"] button[type="submit"]');
                    if (cancelBtn && newStatus !== 'PENDING') {
                        cancelBtn.closest('form').style.display = 'none';
                    }

                    setTimeout(function () {
                        window.location.reload();
                    }, 1200);
                }

                var clientRow = document.querySelector('#client-order-row-' + orderId) || document.querySelector('[data-order-id="' + orderId + '"]');
                if (clientRow) {
                    var statusTd = clientRow.cells && clientRow.cells[5] ? clientRow.cells[5] : clientRow.querySelector('.badge');
                    if (statusTd) {
                        statusTd.innerHTML = '<span class="badge fw-bold px-3 py-2 text-white ' + self.getStatusBadgeClass(newStatus) + '">'
                            + self.escapeHtml(newStatusName) + '</span>';
                    }

                    if (newStatus !== 'PENDING') {
                        var cancelForm = clientRow.querySelector('form[action*="order-action"]');
                        if (cancelForm) cancelForm.remove();
                    }
                    clientRow.classList.add('realtime-pulse-green');
                    setTimeout(function () { clientRow.classList.remove('realtime-pulse-green'); }, 2500);
                }

                var adminRow = document.getElementById('order-row-' + orderId);
                if (adminRow) {
                    var adminStatusCell = adminRow.cells && adminRow.cells[4] ? adminRow.cells[4] : null;
                    if (adminStatusCell) {
                        adminStatusCell.innerHTML = '<span class="badge ' + self.getStatusBadgeClass(newStatus) + '">' + self.escapeHtml(newStatusName) + '</span>';
                    }
                }
            }

            if (type === 'CONTACT_CREATED') {
                if (self.config.role === 'admin') {

                    var pendingBadges = document.querySelectorAll('.stat-card .fs-4, .badge-pending');
                    pendingBadges.forEach(function (el) {
                        var num = parseInt(el.textContent.replace(/\D/g, ''));
                        if (!isNaN(num)) {
                            el.textContent = (num + 1);
                            el.classList.add('realtime-text-flash');
                        }
                    });

                    var contactTable = document.querySelector('table.table tbody');
                    if (contactTable && window.location.href.indexOf('admin/contacts') !== -1) {
                        var contactId = data.contactId;
                        var newContactRow = document.createElement('tr');
                        newContactRow.id = 'contact-row-' + contactId;
                        newContactRow.className = 'realtime-pulse-green';
                        newContactRow.innerHTML = ''
                            + '<td class="fw-bold ps-4"><span class="badge bg-danger me-1">MỚI</span>#' + contactId + '</td>'
                            + '<td><div class="fw-bold text-dark">' + self.escapeHtml(data.fullName) + '</div>'
                            + '<div class="text-danger small"><i class="fa-solid fa-phone me-1"></i>' + self.escapeHtml(data.phone) + '</div>'
                            + '<div class="text-muted small">' + self.escapeHtml(data.email) + '</div></td>'
                            + '<td><span class="badge bg-light text-dark border">' + self.escapeHtml(data.topic) + '</span></td>'
                            + '<td><div class="contact-msg text-dark">' + self.escapeHtml(data.message) + '</div></td>'
                            + '<td><span class="badge-status badge-pending"><i class="bi bi-clock-history"></i> Chưa xử lý</span></td>'
                            + '<td class="text-secondary small">Vừa xong</td>'
                            + '<td class="text-end pe-4">'
                            + '<button type="button" class="btn btn-sm btn-danger px-3 shadow-sm" onclick="window.location.reload();">Xem & Phản hồi</button>'
                            + '</td>';

                        contactTable.insertBefore(newContactRow, contactTable.firstChild);
                    }
                }
            }

            if (type === 'PRODUCT_CHANGED') {
                var pid = data.productId;
                var currentUrl = window.location.href;

                if (currentUrl.indexOf('product/detail') !== -1 && currentUrl.indexOf('id=' + pid) !== -1) {
                    if (data.action === 'delete') {
                        alert('Quản trị viên vừa ngừng kinh doanh sản phẩm này!');
                        window.location.href = self.config.ctx + '/Home';
                        return;
                    }

                    if (data.price) {
                        var priceDisplay = document.getElementById('priceDisplay');
                        if (priceDisplay) {
                            priceDisplay.setAttribute('data-base', data.price);
                            priceDisplay.innerHTML = Number(data.price).toLocaleString('vi-VN') + ' VNĐ';
                            priceDisplay.classList.add('realtime-text-flash');
                            setTimeout(function () { priceDisplay.classList.remove('realtime-text-flash'); }, 2500);
                        }
                    }

                    if (typeof data.stock !== 'undefined') {
                        if (data.stock <= 0) {

                            var buyBtn = document.querySelector('#btnBuyNow') || document.querySelector('.btn-action-primary');
                            var addCartBtn = document.querySelector('#btnAddToCart') || document.querySelector('.btn-action-outline');
                            if (buyBtn) { buyBtn.disabled = true; buyBtn.textContent = 'HẾT HÀNG'; }
                            if (addCartBtn) { addCartBtn.disabled = true; }
                        }
                    }
                }

                var prodCard = document.querySelector('#prod-card-' + pid) || document.querySelector('a[href*="detail?id=' + pid + '"]');
                if (prodCard) {
                    var cardContainer = prodCard.closest('.card') || prodCard.closest('.col-md-3');
                    if (cardContainer && data.action === 'delete') {
                        cardContainer.style.transition = 'all 0.5s';
                        cardContainer.style.opacity = '0';
                        setTimeout(function () { cardContainer.remove(); }, 500);
                    } else if (cardContainer && data.price) {
                        var priceEl = cardContainer.querySelector('.text-danger.fw-bold');
                        if (priceEl) {
                            priceEl.textContent = Number(data.price).toLocaleString('vi-VN') + ' ₫';
                            priceEl.classList.add('realtime-text-flash');
                            setTimeout(function () { priceEl.classList.remove('realtime-text-flash'); }, 2000);
                        }
                    }
                }
            }

            if (type === 'USER_STATUS_CHANGED') {
                if (data.userId == self.config.userId) {
                    if (data.status === 'LOCKED' || data.status === 'INACTIVE') {
                        alert('Tài khoản của bạn vừa bị khóa bởi Quản trị viên!');
                        window.location.href = self.config.ctx + '/login?error=account_locked';
                    }
                }
            }
        },

        initAudioContext: function () {
            try {
                var AudioContext = window.AudioContext || window.webkitAudioContext;
                if (AudioContext) {
                    this.state.audioCtx = new AudioContext();
                }
            } catch (e) {}
        },

        playAudioChime: function (type) {
            try {
                var ctx = this.state.audioCtx;
                if (!ctx) {
                    this.initAudioContext();
                    ctx = this.state.audioCtx;
                }
                if (!ctx) return;
                if (ctx.state === 'suspended') {
                    ctx.resume();
                }

                var now = ctx.currentTime;

                if (type === 'order_new' || type === 'success') {

                    var osc1 = ctx.createOscillator();
                    var gain1 = ctx.createGain();
                    osc1.type = 'sine';
                    osc1.frequency.setValueAtTime(587.33, now);
                    osc1.frequency.exponentialRampToValueAtTime(880, now + 0.12);
                    gain1.gain.setValueAtTime(0.3, now);
                    gain1.gain.exponentialRampToValueAtTime(0.001, now + 0.4);
                    osc1.connect(gain1);
                    gain1.connect(ctx.destination);
                    osc1.start(now);
                    osc1.stop(now + 0.4);

                    var osc2 = ctx.createOscillator();
                    var gain2 = ctx.createGain();
                    osc2.type = 'sine';
                    osc2.frequency.setValueAtTime(1174.66, now + 0.15);
                    gain2.gain.setValueAtTime(0.35, now + 0.15);
                    gain2.gain.exponentialRampToValueAtTime(0.001, now + 0.65);
                    osc2.connect(gain2);
                    gain2.connect(ctx.destination);
                    osc2.start(now + 0.15);
                    osc2.stop(now + 0.65);
                } else if (type === 'cancel' || type === 'warning') {

                    var osc = ctx.createOscillator();
                    var gain = ctx.createGain();
                    osc.type = 'sawtooth';
                    osc.frequency.setValueAtTime(329.63, now);
                    osc.frequency.setValueAtTime(261.63, now + 0.12);
                    gain.gain.setValueAtTime(0.2, now);
                    gain.gain.exponentialRampToValueAtTime(0.001, now + 0.4);
                    osc.connect(gain);
                    gain.connect(ctx.destination);
                    osc.start(now);
                    osc.stop(now + 0.4);
                } else {

                    var osc3 = ctx.createOscillator();
                    var gain3 = ctx.createGain();
                    osc3.type = 'sine';
                    osc3.frequency.setValueAtTime(659.25, now);
                    gain3.gain.setValueAtTime(0.15, now);
                    gain3.gain.exponentialRampToValueAtTime(0.001, now + 0.3);
                    osc3.connect(gain3);
                    gain3.connect(ctx.destination);
                    osc3.start(now);
                    osc3.stop(now + 0.3);
                }
            } catch (e) {}
        },

        initToaster: function () {
            if (document.getElementById('dopc-realtime-toaster')) return;

            var style = document.createElement('style');
            style.id = 'dopc-realtime-styles';
            style.innerHTML = ''
                + '#dopc-realtime-toaster {'
                + '  position: fixed; top: 20px; right: 20px; z-index: 999999;'
                + '  display: flex; flex-direction: column; gap: 12px; pointer-events: none;'
                + '  max-width: 400px; width: calc(100vw - 40px);'
                + '}'
                + '.dopc-toast {'
                + '  pointer-events: auto; background: #18181b; color: #fff;'
                + '  border-radius: 12px; border-left: 5px solid #dc2626;'
                + '  box-shadow: 0 10px 25px -5px rgba(0,0,0,0.4), 0 0 15px rgba(220,38,38,0.25);'
                + '  padding: 14px 16px; display: flex; align-items: flex-start; gap: 12px;'
                + '  animation: dopcToastSlideIn 0.35s cubic-bezier(0.16, 1, 0.3, 1) forwards;'
                + '  transition: all 0.3s ease; position: relative; overflow: hidden; cursor: pointer;'
                + '}'
                + '.dopc-toast.client-style {'
                + '  background: #ffffff; color: #1e293b; border-left: 5px solid #dc2626;'
                + '  box-shadow: 0 10px 25px -5px rgba(0,0,0,0.15), 0 0 15px rgba(220,38,38,0.1);'
                + '  border-top: 1px solid #f1f5f9; border-right: 1px solid #f1f5f9; border-bottom: 1px solid #f1f5f9;'
                + '}'
                + '.dopc-toast-icon {'
                + '  width: 38px; height: 38px; border-radius: 50%; display: flex; align-items: center;'
                + '  justify-content: center; flex-shrink: 0; font-size: 18px;'
                + '  background: rgba(220,38,38,0.15); color: #ef4444;'
                + '}'
                + '.dopc-toast.client-style .dopc-toast-icon {'
                + '  background: #fee2e2; color: #dc2626;'
                + '}'
                + '.dopc-toast-body { flex: 1; min-width: 0; }'
                + '.dopc-toast-title { font-weight: 700; font-size: 14px; margin-bottom: 2px; }'
                + '.dopc-toast-msg { font-size: 13px; opacity: 0.88; line-height: 1.4; word-break: break-word; }'
                + '.dopc-toast-close { background: none; border: none; font-size: 18px; line-height: 1; cursor: pointer; color: inherit; opacity: 0.5; padding: 0 4px; }'
                + '.dopc-toast-close:hover { opacity: 1; }'
                + '.dopc-toast-bar {'
                + '  position: absolute; bottom: 0; left: 0; height: 3px; background: #dc2626; width: 100%;'
                + '  animation: dopcToastProgress 5.5s linear forwards;'
                + '}'
                + '@keyframes dopcToastSlideIn {'
                + '  from { transform: translateX(110%); opacity: 0; }'
                + '  to { transform: translateX(0); opacity: 1; }'
                + '}'
                + '@keyframes dopcToastSlideOut {'
                + '  from { transform: translateX(0); opacity: 1; }'
                + '  to { transform: translateX(110%); opacity: 0; }'
                + '}'
                + '@keyframes dopcToastProgress {'
                + '  from { width: 100%; }'
                + '  to { width: 0%; }'
                + '}'
                + '.realtime-pulse-green {'
                + '  animation: pulseGreen 2.5s ease-out;'
                + '}'
                + '.realtime-pulse-red {'
                + '  animation: pulseRed 2.5s ease-out;'
                + '}'
                + '@keyframes pulseGreen {'
                + '  0% { background-color: rgba(34, 197, 94, 0.35) !important; }'
                + '  100% { background-color: transparent !important; }'
                + '}'
                + '@keyframes pulseRed {'
                + '  0% { background-color: rgba(239, 68, 68, 0.35) !important; }'
                + '  100% { background-color: transparent !important; }'
                + '}'
                + '.realtime-text-flash {'
                + '  animation: textFlash 1.5s ease;'
                + '}'
                + '@keyframes textFlash {'
                + '  0%, 100% { transform: scale(1); }'
                + '  50% { transform: scale(1.15); color: #dc2626 !important; font-weight: 800; }'
                + '}';

            document.head.appendChild(style);

            var toaster = document.createElement('div');
            toaster.id = 'dopc-realtime-toaster';
            document.body.appendChild(toaster);
        },

        showToast: function (ev) {
            var toaster = document.getElementById('dopc-realtime-toaster');
            if (!toaster) return;

            var isClient = this.config.role === 'client';
            var toast = document.createElement('div');
            toast.className = 'dopc-toast' + (isClient ? ' client-style' : '');

            var iconHtml = '<i class="fa-solid fa-bell"></i>';
            if (ev.type.indexOf('ORDER') !== -1) iconHtml = '<i class="fa-solid fa-cart-shopping"></i>';
            if (ev.type.indexOf('CONTACT') !== -1) iconHtml = '<i class="fa-solid fa-envelope"></i>';
            if (ev.type.indexOf('PRODUCT') !== -1) iconHtml = '<i class="fa-solid fa-computer"></i>';
            if (ev.type.indexOf('CANCEL') !== -1) iconHtml = '<i class="fa-solid fa-ban"></i>';

            toast.innerHTML = ''
                + '<div class="dopc-toast-icon">' + iconHtml + '</div>'
                + '<div class="dopc-toast-body">'
                + '  <div class="dopc-toast-title">' + this.escapeHtml(ev.title || 'Thông báo mới') + '</div>'
                + '  <div class="dopc-toast-msg">' + this.escapeHtml(ev.message || '') + '</div>'
                + '</div>'
                + '<button class="dopc-toast-close" title="Đóng">&times;</button>'
                + '<div class="dopc-toast-bar"></div>';

            if (ev.linkUrl) {
                var targetUrl = this.config.ctx + ev.linkUrl;
                toast.onclick = function (e) {
                    if (e.target.classList.contains('dopc-toast-close')) return;
                    window.location.href = targetUrl;
                };
            }

            toast.querySelector('.dopc-toast-close').onclick = function (e) {
                e.stopPropagation();
                toast.style.animation = 'dopcToastSlideOut 0.3s forwards';
                setTimeout(function () { toast.remove(); }, 300);
            };

            toaster.appendChild(toast);

            setTimeout(function () {
                if (toast && toast.parentNode) {
                    toast.style.animation = 'dopcToastSlideOut 0.3s forwards';
                    setTimeout(function () { if (toast.parentNode) toast.remove(); }, 300);
                }
            }, 5500);
        },

        updateConnectionIndicator: function (connected) {
            var dot = document.getElementById('realtime-status-dot');
            if (dot) {
                dot.style.backgroundColor = connected ? '#22c55e' : '#ef4444';
                dot.title = connected ? 'Realtime kết nối tức thời (WebSocket)' : 'Đang dùng Fallback Polling';
            }
        },

        getStatusBadgeClass: function (status) {
            if (!status) return 'bg-secondary';
            switch (status.toUpperCase()) {
                case 'PENDING': return 'bg-warning text-dark';
                case 'CONFIRMED': return 'bg-primary text-white';
                case 'PREPARING': return 'bg-info text-white';
                case 'SHIPPING': return 'bg-info text-dark';
                case 'FINISH':
                case 'COMPLETED': return 'bg-success text-white';
                case 'CANCELLED':
                case 'CLIENT_CANCELLED': return 'bg-danger text-white';
                default: return 'bg-secondary text-white';
            }
        },

        escapeHtml: function (str) {
            if (!str) return '';
            return String(str)
                .replace(/&/g, '&amp;')
                .replace(/</g, '&lt;')
                .replace(/>/g, '&gt;')
                .replace(/"/g, '&quot;')
                .replace(/'/g, '&#039;');
        }
    };

    window.RealtimeSync = RealtimeSync;
})(window, document);
