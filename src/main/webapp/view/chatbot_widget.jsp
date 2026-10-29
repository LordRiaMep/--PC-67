<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="ctx" value="${pageContext.request.contextPath}" />

<style>
.dopc-chat-fab {
        position: fixed;
        bottom: 24px;
        right: 24px;
        z-index: 99998;
        display: flex;
        align-items: center;
        gap: 10px;
        cursor: pointer;
        user-select: none;
        transition: transform 0.25s ease, box-shadow 0.25s ease;
    }

    .dopc-chat-fab:hover {
        transform: translateY(-3px) scale(1.02);
    }

    .dopc-chat-fab-badge {
        background: #111827;
        color: #ffffff;
        font-size: 13px;
        font-weight: 600;
        padding: 8px 14px;
        border-radius: 20px;
        box-shadow: 0 4px 14px rgba(0,0,0,0.18);
        border: 1px solid rgba(255,255,255,0.15);
        display: flex;
        align-items: center;
        gap: 6px;
        white-space: nowrap;
        animation: dopc-pulse 2.2s infinite;
    }

    .dopc-chat-fab-btn {
        width: 60px;
        height: 60px;
        border-radius: 50%;
        background: linear-gradient(135deg, #dc2626 0%, #991b1b 100%);
        color: #ffffff;
        display: flex;
        align-items: center;
        justify-content: center;
        box-shadow: 0 8px 24px rgba(220, 38, 38, 0.45);
        font-size: 26px;
        position: relative;
        transition: background 0.3s;
    }

    .dopc-online-dot {
        position: absolute;
        top: 2px;
        right: 2px;
        width: 14px;
        height: 14px;
        background-color: #22c55e;
        border: 2.5px solid #ffffff;
        border-radius: 50%;
    }

    @keyframes dopc-pulse {
        0%, 100% { box-shadow: 0 4px 14px rgba(220,38,38,0.25); }
        50% { box-shadow: 0 4px 22px rgba(220,38,38,0.5); }
    }

    .dopc-chat-window {
        position: fixed;
        bottom: 24px;
        right: 24px;
        width: 400px;
        max-width: calc(100vw - 32px);
        height: 600px;
        max-height: calc(100vh - 48px);
        background: #ffffff;
        border-radius: 20px;
        box-shadow: 0 16px 48px rgba(0, 0, 0, 0.22);
        display: none;
        flex-direction: column;
        overflow: hidden;
        z-index: 99999;
        border: 1px solid #e5e7eb;
        font-family: system-ui, -apple-system, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
        animation: dopc-slide-up 0.3s cubic-bezier(0.16, 1, 0.3, 1);
    }

    @keyframes dopc-slide-up {
        from {
            opacity: 0;
            transform: translateY(20px) scale(0.96);
        }
        to {
            opacity: 1;
            transform: translateY(0) scale(1);
        }
    }

    .dopc-chat-header {
        background: linear-gradient(135deg, #1e293b 0%, #0f172a 100%);
        color: #ffffff;
        padding: 14px 16px;
        display: flex;
        align-items: center;
        justify-content: space-between;
        border-bottom: 2px solid #dc2626;
    }

    .dopc-chat-avatar {
        width: 42px;
        height: 42px;
        border-radius: 50%;
        background: linear-gradient(135deg, #dc2626, #f97316);
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 20px;
        color: #ffffff;
        box-shadow: 0 2px 8px rgba(0,0,0,0.3);
        position: relative;
    }

    .dopc-chat-info {
        flex: 1;
        margin-left: 12px;
    }

    .dopc-chat-title {
        font-size: 15px;
        font-weight: 700;
        margin: 0;
        line-height: 1.2;
        display: flex;
        align-items: center;
        gap: 6px;
    }

    .dopc-chat-subtitle {
        font-size: 11.5px;
        color: #94a3b8;
        margin: 2px 0 0 0;
        display: flex;
        align-items: center;
        gap: 5px;
    }

    .dopc-chat-header-actions {
        display: flex;
        align-items: center;
        gap: 6px;
    }

    .dopc-chat-hbtn {
        background: rgba(255, 255, 255, 0.1);
        border: none;
        color: #cbd5e1;
        width: 32px;
        height: 32px;
        border-radius: 8px;
        cursor: pointer;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 14px;
        transition: all 0.2s;
    }

    .dopc-chat-hbtn:hover {
        background: rgba(255, 255, 255, 0.22);
        color: #ffffff;
    }

    .dopc-chat-body {
        flex: 1;
        padding: 16px;
        overflow-y: auto;
        background: #f8fafc;
        display: flex;
        flex-direction: column;
        gap: 12px;
        scroll-behavior: smooth;
    }

    .dopc-chat-body::-webkit-scrollbar {
        width: 5px;
    }
    .dopc-chat-body::-webkit-scrollbar-thumb {
        background: #cbd5e1;
        border-radius: 4px;
    }

    .dopc-msg {
        display: flex;
        gap: 8px;
        max-width: 88%;
        animation: dopc-fade-in 0.25s ease;
    }

    @keyframes dopc-fade-in {
        from { opacity: 0; transform: translateY(8px); }
        to { opacity: 1; transform: translateY(0); }
    }

    .dopc-msg-bot {
        align-self: flex-start;
    }

    .dopc-msg-user {
        align-self: flex-end;
        flex-direction: row-reverse;
    }

    .dopc-bubble {
        padding: 10px 14px;
        border-radius: 16px;
        font-size: 13.5px;
        line-height: 1.5;
        position: relative;
        word-break: break-word;
    }

    .dopc-msg-bot .dopc-bubble {
        background: #ffffff;
        color: #1e293b;
        border-top-left-radius: 4px;
        box-shadow: 0 2px 6px rgba(0,0,0,0.05);
        border: 1px solid #e2e8f0;
    }

    .dopc-msg-user .dopc-bubble {
        background: linear-gradient(135deg, #dc2626 0%, #b91c1c 100%);
        color: #ffffff;
        border-top-right-radius: 4px;
        box-shadow: 0 2px 8px rgba(220,38,38,0.25);
    }

    .dopc-msg-time {
        font-size: 10.5px;
        color: #94a3b8;
        margin-top: 4px;
        text-align: right;
    }

    .dopc-msg-user .dopc-msg-time {
        color: rgba(255,255,255,0.8);
    }

    .dopc-products-wrap {
        display: flex;
        flex-direction: column;
        gap: 8px;
        margin-top: 10px;
        width: 100%;
    }

    .dopc-product-card {
        background: #ffffff;
        border: 1px solid #e2e8f0;
        border-radius: 12px;
        padding: 8px 10px;
        display: flex;
        align-items: center;
        gap: 10px;
        transition: transform 0.2s, box-shadow 0.2s;
        text-decoration: none;
        color: inherit;
    }

    .dopc-product-card:hover {
        transform: translateY(-2px);
        box-shadow: 0 4px 12px rgba(0,0,0,0.08);
        border-color: #dc2626;
        color: inherit;
    }

    .dopc-prod-img {
        width: 52px;
        height: 52px;
        border-radius: 8px;
        object-fit: cover;
        background: #f1f5f9;
        flex-shrink: 0;
    }

    .dopc-prod-info {
        flex: 1;
        min-width: 0;
    }

    .dopc-prod-name {
        font-size: 12.5px;
        font-weight: 600;
        color: #0f172a;
        margin-bottom: 2px;
        display: -webkit-box;
        -webkit-line-clamp: 2;
        -webkit-box-orient: vertical;
        overflow: hidden;
        line-height: 1.3;
    }

    .dopc-prod-price {
        font-size: 12.5px;
        font-weight: 700;
        color: #dc2626;
    }

    .dopc-prod-btn {
        font-size: 11px;
        background: #fee2e2;
        color: #dc2626;
        padding: 4px 8px;
        border-radius: 6px;
        font-weight: 600;
        white-space: nowrap;
        border: none;
    }

    .dopc-quick-bar {
        padding: 8px 14px;
        background: #ffffff;
        border-top: 1px solid #f1f5f9;
        display: flex;
        gap: 6px;
        overflow-x: auto;
        white-space: nowrap;
        scrollbar-width: none;
    }
    .dopc-quick-bar::-webkit-scrollbar {
        display: none;
    }

    .dopc-chip {
        display: inline-flex;
        align-items: center;
        gap: 4px;
        background: #f1f5f9;
        color: #334155;
        font-size: 12px;
        padding: 5px 11px;
        border-radius: 14px;
        cursor: pointer;
        border: 1px solid #e2e8f0;
        transition: all 0.2s;
        flex-shrink: 0;
    }

    .dopc-chip:hover {
        background: #dc2626;
        color: #ffffff;
        border-color: #dc2626;
    }

    .dopc-typing {
        display: inline-flex;
        align-items: center;
        gap: 4px;
        padding: 8px 12px;
        background: #ffffff;
        border: 1px solid #e2e8f0;
        border-radius: 14px;
        border-top-left-radius: 4px;
        width: fit-content;
    }

    .dopc-dot {
        width: 6px;
        height: 6px;
        background: #94a3b8;
        border-radius: 50%;
        animation: dopc-bounce 1.4s infinite;
    }

    .dopc-dot:nth-child(2) { animation-delay: 0.2s; }
    .dopc-dot:nth-child(3) { animation-delay: 0.4s; }

    @keyframes dopc-bounce {
        0%, 80%, 100% { transform: translateY(0); }
        40% { transform: translateY(-6px); }
    }

    .dopc-chat-footer {
        padding: 10px 14px;
        background: #ffffff;
        border-top: 1px solid #e2e8f0;
        display: flex;
        align-items: center;
        gap: 8px;
    }

    .dopc-chat-input {
        flex: 1;
        border: 1px solid #cbd5e1;
        border-radius: 20px;
        padding: 9px 14px;
        font-size: 13.5px;
        outline: none;
        transition: border-color 0.2s, box-shadow 0.2s;
        background: #f8fafc;
    }

    .dopc-chat-input:focus {
        border-color: #dc2626;
        background: #ffffff;
        box-shadow: 0 0 0 3px rgba(220, 38, 38, 0.12);
    }

    .dopc-chat-send-btn {
        width: 38px;
        height: 38px;
        border-radius: 50%;
        background: #dc2626;
        color: #ffffff;
        border: none;
        display: flex;
        align-items: center;
        justify-content: center;
        cursor: pointer;
        font-size: 15px;
        transition: transform 0.2s, background 0.2s;
        flex-shrink: 0;
    }

    .dopc-chat-send-btn:hover {
        background: #b91c1c;
        transform: scale(1.05);
    }

    .dopc-chat-send-btn:disabled {
        background: #cbd5e1;
        cursor: not-allowed;
        transform: none;
    }

    .dopc-bot-badge {
        display: inline-block;
        font-size: 10px;
        font-weight: 700;
        background: #ef4444;
        color: #ffffff;
        padding: 1px 6px;
        border-radius: 4px;
        margin-left: 4px;
        letter-spacing: 0.5px;
    }
</style>

<div class="dopc-chat-fab" id="dopcChatFab" onclick="dopcToggleChat()">
    <div class="dopc-chat-fab-badge d-none d-sm-flex">
        <span>🤖 Tư vấn PC 24/7</span>
    </div>
    <div class="dopc-chat-fab-btn">
        <i class="bi bi-chat-dots-fill"></i>
        <span class="dopc-online-dot"></span>
    </div>
</div>

<div class="dopc-chat-window" id="dopcChatWindow">

    <div class="dopc-chat-header">
        <div class="dopc-chat-avatar">
            <i class="bi bi-robot"></i>
            <span class="dopc-online-dot" style="top:-2px; right:-2px;"></span>
        </div>
        <div class="dopc-chat-info">
            <div class="dopc-chat-title">
                Độ-PC 67 Assistant
                <span class="dopc-bot-badge">AI 24/7</span>
            </div>
            <div class="dopc-chat-subtitle">
                <span class="badge bg-success p-1 rounded-circle" style="width:6px; height:6px;"></span>
                <span>Tư vấn PC & Hỗ trợ khách hàng</span>
            </div>
        </div>
        <div class="dopc-chat-header-actions">
            <button class="dopc-chat-hbtn" title="Xóa lịch sử trò chuyện" onclick="dopcClearChat()">
                <i class="bi bi-arrow-counterclockwise"></i>
            </button>
            <button class="dopc-chat-hbtn" title="Thu nhỏ" onclick="dopcToggleChat()">
                <i class="bi bi-dash-lg"></i>
            </button>
        </div>
    </div>

    <div class="dopc-chat-body" id="dopcChatBody">

    </div>

    <div class="dopc-quick-bar" id="dopcQuickBar">
        <span class="dopc-chip" onclick="dopcSendMessageCustom('Gợi ý PC AMD 30tr')">🔥 PC AMD 30tr</span>
        <span class="dopc-chip" onclick="dopcSendMessageCustom('PC RTX 5060')">🚀 PC RTX 5060</span>
        <span class="dopc-chip" onclick="dopcSendMessageCustom('So sánh chip Intel và AMD')">💡 Intel vs AMD</span>
        <span class="dopc-chip" onclick="dopcSendMessageCustom('Nghẽn cổ chai là gì?')">⚙️ Nghẽn cổ chai?</span>
        <span class="dopc-chip" onclick="dopcSendAction('budget_10_15')">🎮 Gaming 10-15tr</span>
        <span class="dopc-chip" onclick="dopcSendAction('budget_15_25')">⚡ Đồ họa 15-25tr</span>
        <span class="dopc-chip" onclick="dopcSendAction('budget_under_10')">🖥️ Dưới 10tr</span>
        <span class="dopc-chip" onclick="dopcSendAction('budget_above_25')">👑 High-End > 25tr</span>
        <span class="dopc-chip" onclick="dopcSendAction('faq_warranty')">🛡️ Bảo hành 1 đổi 1</span>
        <span class="dopc-chip" onclick="dopcSendAction('faq_installment')">💳 Trả góp 0%</span>
        <span class="dopc-chip" onclick="dopcSendAction('service_assembly')">🛠️ Lắp ráp tận nơi</span>
        <span class="dopc-chip" onclick="dopcSendAction('service_tradein')">🔄 Thu cũ đổi mới</span>
        <span class="dopc-chip" onclick="dopcSendAction('faq_shipping')">🚚 Giao hàng COD</span>
        <span class="dopc-chip" onclick="dopcSendAction('faq_contact')">📞 Hotline shop</span>
    </div>

    <div class="dopc-chat-footer">
        <input type="text"
               class="dopc-chat-input"
               id="dopcChatInput"
               placeholder="Hỏi về PC AMD 30tr, RTX 5060, bảo hành..."
               autocomplete="off"
               onkeydown="dopcHandleKeyDown(event)" />
        <button class="dopc-chat-send-btn" id="dopcSendBtn" onclick="dopcSendMessage()" title="Gửi">
            <i class="bi bi-send-fill"></i>
        </button>
    </div>
</div>

<script>
(function() {
    const CTX_PATH = '${ctx}';
    const CHAT_API = CTX_PATH + '/api/chat';
    const STORAGE_KEY = 'dopc_chat_history_v3';
    const OPEN_STATE_KEY = 'dopc_chat_open_state';

    let isSending = false;

    const DEFAULT_WELCOME = {
        role: 'bot',
        text: 'Xin chào bạn! 👋 Em là **Trợ lý AI Độ-PC 67** (được tối ưu như một phiên bản Gemini thu nhỏ chuyên sâu về công nghệ và phần cứng máy tính).\n\nEm có thể hỗ trợ bạn:\n• 🖥️ **Tư vấn cấu hình PC:** Ví dụ *\"Gợi ý PC AMD 30tr\"*, *\"PC Intel 20tr\"*, *\"PC chạy RTX 5060\"*...\n• 💡 **Giải đáp kiến thức công nghệ:** So sánh Intel vs AMD, giải thích nghẽn cổ chai, RAM, SSD, màn hình Hz...\n• 💻 **Kiến thức IT & Lập trình:** Học code cần máy gì, giải thích AI, Web, xử lý lỗi máy tính...\n• 🛡️ **Chính sách shop:** Bảo hành 1 đổi 1 trong 30 ngày, trả góp 0%, ship COD toàn quốc.\n\nBạn đang quan tâm đến bộ máy tầm bao nhiêu tiền hoặc cần hỏi đáp gì cứ nhắn cho em nhé!',
        time: getCurrentTime(),
        products: []
    };

    window.addEventListener('DOMContentLoaded', function() {
        renderStoredMessages();
        const isOpen = sessionStorage.getItem(OPEN_STATE_KEY) === 'true';
        if (isOpen) {
            openChat();
        }
    });

    window.dopcToggleChat = function() {
        const win = document.getElementById('dopcChatWindow');
        const fab = document.getElementById('dopcChatFab');
        if (win.style.display === 'flex') {
            win.style.display = 'none';
            fab.style.display = 'flex';
            sessionStorage.setItem(OPEN_STATE_KEY, 'false');
        } else {
            win.style.display = 'flex';
            fab.style.display = 'none';
            sessionStorage.setItem(OPEN_STATE_KEY, 'true');
            scrollToBottom();
            setTimeout(() => {
                const inp = document.getElementById('dopcChatInput');
                if (inp) inp.focus();
            }, 100);
        }
    };

    function openChat() {
        const win = document.getElementById('dopcChatWindow');
        const fab = document.getElementById('dopcChatFab');
        if (win && fab) {
            win.style.display = 'flex';
            fab.style.display = 'none';
            scrollToBottom();
        }
    }

    window.dopcSendMessage = function() {
        const input = document.getElementById('dopcChatInput');
        const text = input ? input.value.trim() : '';
        if (!text || isSending) return;

        input.value = '';
        appendMessage('user', text, null);
        callChatApi({ message: text });
    };

    window.dopcSendAction = function(actionCode, label) {
        if (isSending) return;
        const actionLabels = {
            'budget_10_15': 'Tư vấn PC 10 - 15 triệu',
            'budget_15_25': 'Tư vấn PC 15 - 25 triệu',
            'budget_under_10': 'Tư vấn PC dưới 10 triệu',
            'budget_above_25': 'Tư vấn PC High-End trên 25 triệu',
            'faq_warranty': 'Chính sách bảo hành & Đổi trả',
            'faq_installment': 'Hướng dẫn mua trả góp 0%',
            'service_assembly': 'Dịch vụ lắp ráp PC theo yêu cầu',
            'service_tradein': 'Chương trình Thu cũ đổi mới',
            'faq_shipping': 'Chính sách giao hàng & Ship COD',
            'faq_contact': 'Thông tin liên hệ & Hotline'
        };
        const userText = label || actionLabels[actionCode] || 'Tư vấn nhanh';
        appendMessage('user', userText, null);
        callChatApi({ action: actionCode });
    };

    window.dopcHandleKeyDown = function(e) {
        if (e.key === 'Enter' && !e.shiftKey) {
            e.preventDefault();
            dopcSendMessage();
        }
    };

    window.dopcClearChat = function() {
        if (confirm('Bạn có muốn làm mới cuộc trò chuyện?')) {
            sessionStorage.removeItem(STORAGE_KEY);
            renderStoredMessages();
        }
    };

    function callChatApi(payload) {
        isSending = true;
        showTypingIndicator();

        fetch(CHAT_API, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json; charset=UTF-8'
            },
            body: JSON.stringify(payload)
        })
        .then(res => res.json())
        .then(data => {
            hideTypingIndicator();
            isSending = false;

            if (data && data.status === 'success') {
                appendMessage('bot', data.reply, data.products);

                if (data.suggestions && data.suggestions.length > 0) {
                    renderQuickSuggestions(data.suggestions);
                }
            } else {
                appendMessage('bot', 'Dạ hiện tại hệ thống đang bận. Bạn vui lòng thử lại hoặc gọi Hotline **0904 112 618** để được hỗ trợ ngay nhé!', []);
            }
        })
        .catch(err => {
            console.error('Lỗi kết nối Chatbot:', err);
            hideTypingIndicator();
            isSending = false;
            appendMessage('bot', 'Dạ hệ thống kết nối tạm thời bị gián đoạn. Bạn vui lòng liên hệ Hotline/Zalo **0904 112 618** để được tư vấn trực tiếp 24/7 ạ!', []);
        });
    }

    function appendMessage(role, text, products) {
        const history = getStoredMessages();
        const msg = {
            role: role,
            text: text,
            time: getCurrentTime(),
            products: products || []
        };
        history.push(msg);
        sessionStorage.setItem(STORAGE_KEY, JSON.stringify(history));
        renderSingleMessage(msg);
        scrollToBottom();
    }

    function getStoredMessages() {
        try {
            const raw = sessionStorage.getItem(STORAGE_KEY);
            if (raw) return JSON.parse(raw);
        } catch (e) {}
        return [DEFAULT_WELCOME];
    }

    function renderStoredMessages() {
        const body = document.getElementById('dopcChatBody');
        if (!body) return;
        body.innerHTML = '';
        const history = getStoredMessages();
        history.forEach(m => renderSingleMessage(m));
        scrollToBottom();
    }

    function renderSingleMessage(msg) {
        const body = document.getElementById('dopcChatBody');
        if (!body) return;

        const isBot = msg.role === 'bot';
        const msgDiv = document.createElement('div');
        msgDiv.className = 'dopc-msg ' + (isBot ? 'dopc-msg-bot' : 'dopc-msg-user');

        let html = '';
        if (isBot) {
            html += '<div class="dopc-chat-avatar" style="width:30px; height:30px; font-size:14px; flex-shrink:0;"><i class="bi bi-robot"></i></div>';
        }

        html += '<div class="dopc-bubble">';
        html += formatMarkdown(msg.text);

        if (msg.products && msg.products.length > 0) {
            html += '<div class="dopc-products-wrap">';
            msg.products.forEach(p => {
                const imgUrl = p.image ? (p.image.startsWith('http') ? p.image : CTX_PATH + '/' + p.image) : (CTX_PATH + '/assets/images/no-image.png');
                html += '<a href="' + CTX_PATH + '/product/detail?id=' + p.id + '" target="_blank" class="dopc-product-card">';
                html += '<img src="' + imgUrl + '" class="dopc-prod-img" onerror="this.src=\'' + CTX_PATH + '/assets/images/logo.png\'" />';
                html += '<div class="dopc-prod-info">';
                html += '<div class="dopc-prod-name" title="' + escapeHtml(p.name) + '">' + escapeHtml(p.name) + '</div>';
                html += '<div class="dopc-prod-price">' + (p.formattedPrice || (p.price.toLocaleString('vi-VN') + ' đ')) + '</div>';
                html += '</div>';
                html += '<button type="button" class="dopc-prod-btn">Xem chi tiết <i class="bi bi-arrow-right"></i></button>';
                html += '</a>';
            });
            html += '</div>';
        }

        html += '<div class="dopc-msg-time">' + (msg.time || '') + '</div>';
        html += '</div>';

        msgDiv.innerHTML = html;
        body.appendChild(msgDiv);
    }

    function renderQuickSuggestions(suggestions) {
        const bar = document.getElementById('dopcQuickBar');
        if (!bar || !suggestions) return;
        let html = '';
        suggestions.forEach(s => {
            html += '<span class="dopc-chip" onclick="dopcSendMessageCustom(\'' + escapeHtml(s) + '\')">' + escapeHtml(s) + '</span>';
        });
        bar.innerHTML = html;
    }

    window.dopcSendMessageCustom = function(text) {
        appendMessage('user', text, null);
        callChatApi({ message: text });
    };

    function showTypingIndicator() {
        hideTypingIndicator();
        const body = document.getElementById('dopcChatBody');
        if (!body) return;

        const typingDiv = document.createElement('div');
        typingDiv.className = 'dopc-msg dopc-msg-bot';
        typingDiv.id = 'dopcTypingIndicator';
        typingDiv.innerHTML = `
            <div class="dopc-chat-avatar" style="width:30px; height:30px; font-size:14px; flex-shrink:0;">
                <i class="bi bi-robot"></i>
            </div>
            <div class="dopc-typing">
                <span class="dopc-dot"></span>
                <span class="dopc-dot"></span>
                <span class="dopc-dot"></span>
            </div>
        `;
        body.appendChild(typingDiv);
        scrollToBottom();
    }

    function hideTypingIndicator() {
        const ind = document.getElementById('dopcTypingIndicator');
        if (ind) ind.remove();
    }

    function scrollToBottom() {
        const body = document.getElementById('dopcChatBody');
        if (body) {
            setTimeout(() => {
                body.scrollTop = body.scrollHeight;
            }, 30);
        }
    }

    function getCurrentTime() {
        const d = new Date();
        const h = String(d.getHours()).padStart(2, '0');
        const m = String(d.getMinutes()).padStart(2, '0');
        return h + ':' + m;
    }

    function formatMarkdown(text) {
        if (!text) return '';
        let s = escapeHtml(text);

        s = s.replace(/\*\*(.*?)\*\*/g, '<strong>$1</strong>');

        s = s.replace(/\*(.*?)\*/g, '<em>$1</em>');

        s = s.replace(/(?:^|\n)[-•]\s+(.*?)(?=\n|$)/g, '<div style="margin-left: 10px; margin-bottom: 2px;">• $1</div>');

        s = s.replace(/\n/g, '<br/>');
        return s;
    }

    function escapeHtml(str) {
        if (!str) return '';
        return String(str)
            .replace(/&/g, '&amp;')
            .replace(/</g, '&lt;')
            .replace(/>/g, '&gt;')
            .replace(/"/g, '&quot;')
            .replace(/'/g, '&#039;');
    }
})();
</script>
