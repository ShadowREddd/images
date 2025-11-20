import streamlit as st
import streamlit.components.v1 as components

# ==========================================
# 👇 GitHub 設定
# ==========================================
GITHUB_USER = "ShadowREddd"
REPO_NAME = "-"
BRANCH_NAME = "main"
BASE_URL = f"https://raw.githubusercontent.com/{GITHUB_USER}/{REPO_NAME}/{BRANCH_NAME}/"
# ==========================================

st.set_page_config(page_title="食際行動家(手機版)", layout="wide", initial_sidebar_state="collapsed")

html_code = """
<!DOCTYPE html>
<html lang="zh-TW">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
    <style>
        /* --- 手機版核心樣式 --- */
        * { box-sizing: border-box; -webkit-tap-highlight-color: transparent; }
        body { font-family: -apple-system, BlinkMacSystemFont, sans-serif; background: #f5f5f5; margin: 0; padding-bottom: 80px; user-select: none; }
        
        /* 底部導覽列 (App 風格) */
        .bottom-nav {
            position: fixed; bottom: 0; left: 0; width: 100%; height: 65px; background: white;
            display: flex; justify-content: space-around; align-items: center;
            box-shadow: 0 -2px 10px rgba(0,0,0,0.05); z-index: 5000; border-top: 1px solid #eee;
        }
        .nav-item { flex: 1; text-align: center; color: #999; font-size: 0.75rem; background:none; border:none; }
        .nav-item.active { color: #d9534f; font-weight: bold; }
        .nav-icon { font-size: 1.4rem; display: block; margin-bottom: 2px; }

        /* 頁面切換 */
        .page { display: none; padding: 15px; animation: fadeInUp 0.3s; }
        @keyframes fadeInUp { from { opacity: 0; transform: translateY(10px); } to { opacity: 1; transform: translateY(0); } }
        
        /* 商品網格 (手機雙欄) */
        .grid { display: grid; grid-template-columns: 1fr 1fr; gap: 10px; }
        .card { background: white; border-radius: 10px; overflow: hidden; box-shadow: 0 2px 5px rgba(0,0,0,0.05); }
        .card-img { width: 100%; height: 150px; object-fit: cover; }
        .card-body { padding: 10px; }
        .card-title { font-size: 0.95rem; font-weight: bold; margin-bottom: 5px; color: #333; }
        .price { color: #d9534f; font-weight: bold; font-size: 1rem; }

        /* 詳情頁 (滿版圖) */
        .detail-hero img { width: 100%; height: 300px; object-fit: cover; }
        .detail-info { background: white; padding: 20px; border-radius: 20px 20px 0 0; margin-top: -20px; position: relative; min-height: 50vh; }
        
        /* 彈跳視窗 (由下往上滑出 Bottom Sheet) */
        .modal { display: none; position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(0,0,0,0.5); z-index: 6000; align-items: flex-end; }
        .modal-content { background: white; width: 100%; max-height: 80vh; border-radius: 20px 20px 0 0; padding: 20px; animation: slideUp 0.3s; display: flex; flex-direction: column; }
        @keyframes slideUp { from { transform: translateY(100%); } to { transform: translateY(0); } }
        
        /* 按鈕 */
        .btn { width: 100%; padding: 12px; border-radius: 12px; border: none; font-weight: bold; margin-top: 10px; }
        .btn-primary { background: #d9534f; color: white; }
        .btn-outline { background: white; border: 1px solid #ddd; color: #555; }
        
        /* 食譜卡片 */
        .recipe-card { background: white; border-radius: 12px; margin-bottom: 15px; overflow: hidden; box-shadow: 0 2px 5px rgba(0,0,0,0.05); display: flex; }
        .recipe-img { width: 100px; height: 100px; object-fit: cover; }
        .recipe-info { padding: 10px; flex: 1; }

        /* 登入封面 */
        #splash { position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: white; z-index: 9999; display: flex; justify-content: center; align-items: center; transition: opacity 0.5s; }
        .splash-logo { width: 60%; animation: pulse 2s infinite; }
        @keyframes pulse { 0% { transform: scale(0.95); } 50% { transform: scale(1.05); } 100% { transform: scale(0.95); } }
    </style>
</head>
<body>
    <div id="splash" onclick="this.style.opacity=0; setTimeout(()=>this.style.display='none',500)">
        <img src="images/食際行動家.png" class="splash-logo">
        <div style="position:absolute; bottom:50px; color:#999;">輕觸開始</div>
    </div>

    <div id="page-market" class="page" style="display:block;">
        <h2 style="margin:10px 0; text-align:center;">生鮮市集</h2>
        <div id="grid-products" class="grid"></div>
    </div>

    <div id="page-recipe" class="page">
        <div style="display:flex; justify-content:space-between; align-items:center;">
            <h2>食譜牆</h2>
            <button class="btn-outline" style="width:auto; padding:5px 15px;" onclick="showCreateRecipe()">＋ 自訂</button>
        </div>
        <div id="list-recipes"></div>
    </div>

    <div id="page-detail" class="page" style="padding:0;">
        <div class="detail-hero">
            <button onclick="switchTab('market')" style="position:absolute; top:20px; left:20px; width:40px; height:40px; border-radius:50%; background:rgba(255,255,255,0.8); z-index:10;">←</button>
            <img id="dt-img" src="">
        </div>
        <div class="detail-info">
            <h1 id="dt-name" style="margin:0;"></h1>
            <div id="dt-price" style="color:#d9534f; font-size:1.5rem; font-weight:bold; margin:10px 0;"></div>
            <p style="color:#666;">產地：<span id="dt-origin"></span> | 保存：<span id="dt-storage"></span></p>
            <button class="btn btn-primary" onclick="addToCart()">加入購物車</button>
            <button class="btn btn-outline" onclick="findRecipe()">找相關料理</button>
        </div>
    </div>

    <div id="modal-cart" class="modal" onclick="if(event.target===this) closeModal('modal-cart')">
        <div class="modal-content">
            <h3>我的購物車</h3>
            <div id="cart-list" style="flex:1; overflow-y:auto;"></div>
            <div style="border-top:1px solid #eee; padding-top:10px; margin-top:10px;">
                <div style="display:flex; justify-content:space-between; font-weight:bold;"><span>總計</span><span id="cart-total">$0</span></div>
                <button class="btn btn-primary" onclick="alert('結帳成功'); cart=[]; updateCartUI(); closeModal('modal-cart')">結帳</button>
            </div>
        </div>
    </div>

    <div class="bottom-nav">
        <button class="nav-item active" onclick="switchTab('market')" id="nav-market"><span class="nav-icon">🥦</span>市集</button>
        <button class="nav-item" onclick="switchTab('recipe')" id="nav-recipe"><span class="nav-icon">👨‍🍳</span>食譜</button>
        <button class="nav-item" onclick="openModal('modal-cart')"><span class="nav-icon">🛒<span id="cart-badge" style="font-size:0.8rem; color:#d9534f;">0</span></span>購物車</button>
    </div>

    <script>
        // 資料庫
        const products = [
            {id:"P1", name:"蘋果", price:139, img:"images/蘋果.jpg", origin:"美國", storage:"冷藏"},
            {id:"P2", name:"香蕉", price:80, img:"images/香蕉.jpg", origin:"台灣", storage:"常溫"},
            {id:"P3", name:"高麗菜", price:160, img:"images/高麗菜.JPG", origin:"台灣", storage:"冷藏"},
            {id:"P4", name:"番茄", price:70, img:"images/番茄.JPG", origin:"台灣", storage:"冷藏"},
            {id:"P5", name:"洋蔥", price:50, img:"images/洋蔥.jpg", origin:"美國", storage:"常溫"},
            {id:"P6", name:"地瓜", price:190, img:"images/地瓜.jpg", origin:"台灣", storage:"常溫"},
            {id:"P7", name:"柳橙", price:120, img:"images/柳橙.JPG", origin:"美國", storage:"冷藏"},
            {id:"P8", name:"菠菜", price:90, img:"images/菠菜.JPG", origin:"台灣", storage:"冷藏"},
            {id:"P9", name:"胡蘿蔔", price:60, img:"images/胡蘿蔔.jpg", origin:"韓國", storage:"冷藏"},
            {id:"P10", name:"鳳梨", price:155, img:"images/鳳梨.jpg", origin:"美國", storage:"冷凍"}
        ];
        
        let recipes = [
            {id:"R1", name:"綜合沙拉", img:"images/綜合蔬果沙拉.jpg", cal:220, steps:"切塊拌勻"},
            {id:"R2", name:"番茄高麗菜", img:"images/番茄炒高麗菜.jpg", cal:180, steps:"大火快炒"},
            {id:"R3", name:"烤地瓜", img:"images/蜂蜜烤地瓜.jpg", cal:250, steps:"烤箱200度"},
            {id:"R4", name:"鳳梨蘋果汁", img:"images/鳳梨蘋果汁.jpg", cal:150, steps:"打成果汁"},
            {id:"R5", name:"香蕉冰沙", img:"images/香蕉柳橙冰沙.jpg", cal:180, steps:"加冰塊打勻"},
            {id:"R6", name:"烤蔬菜", img:"images/義式烤蔬菜.jpg", cal:200, steps:"撒鹽烤熟"}
        ];

        let cart = [];
        let currentPid = null;

        // 初始化
        function init() {
            // 渲染商品
            document.getElementById('grid-products').innerHTML = products.map(p => `
                <div class="card" onclick="showDetail('${p.id}')">
                    <img src="${p.img}" class="card-img">
                    <div class="card-body">
                        <div class="card-title">${p.name}</div>
                        <div class="price">$${p.price}</div>
                    </div>
                </div>
            `).join('');

            // 渲染食譜
            renderRecipes();
        }

        function renderRecipes() {
            document.getElementById('list-recipes').innerHTML = recipes.map(r => `
                <div class="recipe-card" onclick="alert('做法：' + '${r.steps}')">
                    <img src="${r.img}" class="recipe-img" onerror="this.src='https://via.placeholder.com/100'">
                    <div class="recipe-info">
                        <div style="font-weight:bold;">${r.name}</div>
                        <div style="color:#666; font-size:0.9rem;">🔥 ${r.cal} kcal</div>
                        <div style="color:#d9534f; font-size:0.8rem;">點擊看做法</div>
                    </div>
                </div>
            `).join('');
        }

        // 頁面切換
        function switchTab(tab) {
            document.querySelectorAll('.page').forEach(p => p.style.display = 'none');
            document.querySelectorAll('.nav-item').forEach(n => n.classList.remove('active'));
            document.getElementById('page-'+tab).style.display = 'block';
            document.getElementById('nav-'+tab).classList.add('active');
            window.scrollTo(0,0);
        }

        function showDetail(pid) {
            currentPid = pid;
            const p = products.find(x => x.id === pid);
            document.getElementById('dt-img').src = p.img;
            document.getElementById('dt-name').innerText = p.name;
            document.getElementById('dt-price').innerText = '$' + p.price;
            document.getElementById('dt-origin').innerText = p.origin;
            document.getElementById('dt-storage').innerText = p.storage;
            
            document.getElementById('page-market').style.display = 'none';
            document.getElementById('page-detail').style.display = 'block';
        }

        function addToCart() {
            if(!currentPid) return;
            const p = products.find(x => x.id === currentPid);
            const item = cart.find(x => x.id === currentPid);
            if(item) item.qty++; else cart.push({id:p.id, name:p.name, price:p.price, qty:1});
            updateCartUI();
            alert('已加入購物車');
        }

        function updateCartUI() {
            const total = cart.reduce((sum, i) => sum + i.price*i.qty, 0);
            const count = cart.reduce((sum, i) => sum + i.qty, 0);
            document.getElementById('cart-badge').innerText = count;
            document.getElementById('cart-total').innerText = '$' + total;
            document.getElementById('cart-list').innerHTML = cart.map(i => `
                <div style="display:flex; justify-content:space-between; padding:10px 0; border-bottom:1px solid #f5f5f5;">
                    <span>${i.name} x ${i.qty}</span><span>$${i.price*i.qty}</span>
                </div>
            `).join('');
        }

        function findRecipe() {
            const p = products.find(x => x.id === currentPid);
            alert('正在為您尋找「'+p.name+'」的食譜...');
            switchTab('recipe');
        }

        function showCreateRecipe() {
            const name = prompt("請輸入食譜名稱：");
            if(name) {
                recipes.unshift({id:"C"+Date.now(), name:name, img:"https://via.placeholder.com/100", cal:0, steps:"自訂食譜"});
                renderRecipes();
            }
        }

        function openModal(id) { document.getElementById(id).style.display = 'flex'; }
        function closeModal(id) { document.getElementById(id).style.display = 'none'; }

        window.onload = init;
    </script>
</body>
</html>
"""

# 手機版圖片路徑替換
final_mobile_html = html_code.replace("images/", BASE_URL)
components.html(final_mobile_html, height=1000, scrolling=True)
