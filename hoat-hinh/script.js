const films = [
    { id: 'meadow', title: 'Dạo chơi trên đồng cỏ', type: 'local', src: 'assets/meadow.mp4', image: 'assets/meadow.png', views: 1250, date: '2026-10-10', author: 'Hoạt hình mẫu', quality: 'HD 720p · Không lời thoại', description: 'Đoạn hoạt hình mẫu về chú thỏ trắng trên đồng cỏ, được tạo cho bài thực hành. Video nằm ngay trong thư mục assets và có thể xem không cần mạng.' },
    { id: 'bunny', title: 'Big Buck Bunny — Chú thỏ lớn', type: 'youtube', src: 'YE7VzlLtp-4', image: 'assets/bunny.png', views: 9800, date: '2026-10-09', author: 'Blender Foundation', quality: 'YouTube · Chất lượng tùy nguồn', description: 'Phim hoạt hình Big Buck Bunny được nhúng bằng iframe. Cần kết nối Internet; khả năng phát và quảng cáo phụ thuộc YouTube. Phim có một số tình huống trêu chọc và rượt đuổi.' }
];
const list = document.getElementById('film-list');
const video = document.getElementById('video');
const youtube = document.getElementById('youtube');
let selected = films[0];
let onlyFavorites = false;
let favorites = new Set();
let objectUrl;
try { favorites = new Set(JSON.parse(localStorage.getItem('cartoon-favorites') || '[]')); } catch (_) {}
const normalize = text => text.normalize('NFD').replace(/[\u0300-\u036f]/g, '').replace(/đ/g, 'd').toLowerCase();
function renderList() {
    const query = normalize(document.getElementById('search').value);
    const sort = document.getElementById('sort').value;
    const items = films.filter(f => normalize(f.title).includes(query) && (!onlyFavorites || favorites.has(f.id))).sort((a, b) => sort === 'views' ? b.views - a.views : b.date.localeCompare(a.date));
    list.replaceChildren();
    items.forEach(f => {
        const button = document.createElement('button');
        button.className = 'film' + (selected.id === f.id ? ' selected' : '');
        button.type = 'button';
        button.setAttribute('aria-pressed', String(selected.id === f.id));
        const img = document.createElement('img'); img.src = f.image; img.alt = f.title;
        const title = document.createElement('strong'); title.textContent = f.title;
        const meta = document.createElement('small'); meta.textContent = `${f.views.toLocaleString('vi-VN')} lượt xem · ${f.author}`;
        button.append(img, title, meta);
        button.addEventListener('click', () => selectFilm(f));
        list.append(button);
    });
    document.getElementById('empty').hidden = items.length > 0;
}
function selectFilm(f) {
    video.pause();
    youtube.removeAttribute('src');
    if (objectUrl) { URL.revokeObjectURL(objectUrl); objectUrl = undefined; }
    selected = f;
    video.hidden = f.type !== 'local'; youtube.hidden = f.type !== 'youtube';
    if (f.type === 'local') { video.src = f.src; video.poster = f.image || ''; video.load(); }
    else { youtube.src = `https://www.youtube-nocookie.com/embed/${f.src}?rel=0`; }
    document.getElementById('film-title').textContent = f.title;
    document.getElementById('film-meta').textContent = `${f.author} · ${f.quality}`;
    document.getElementById('description').textContent = f.description;
    updateFavorite(); renderList();
}
function updateFavorite() {
    const button = document.getElementById('favorite');
    button.disabled = selected.id === 'custom';
    button.setAttribute('aria-pressed', String(favorites.has(selected.id)));
    button.textContent = favorites.has(selected.id) ? '♥ Đã yêu thích' : '♡ Yêu thích';
}
document.getElementById('favorite').addEventListener('click', () => {
    if (favorites.has(selected.id)) favorites.delete(selected.id); else favorites.add(selected.id);
    try { localStorage.setItem('cartoon-favorites', JSON.stringify([...favorites])); } catch (_) {}
    updateFavorite(); renderList();
});
document.getElementById('search').addEventListener('input', renderList);
document.getElementById('sort').addEventListener('change', renderList);
['all', 'favorites'].forEach(id => document.getElementById(id).addEventListener('click', () => {
    onlyFavorites = id === 'favorites';
    document.getElementById('all').classList.toggle('active', !onlyFavorites);
    document.getElementById('favorites').classList.toggle('active', onlyFavorites);
    renderList();
}));
document.getElementById('local-file').addEventListener('change', event => {
    const file = event.target.files[0]; if (!file) return;
    selectFilm({ id: 'custom', title: file.name, type: 'local', src: '', author: 'Video từ máy', quality: 'Chất lượng và âm thanh theo file gốc', description: 'File được phát trực tiếp từ máy của bạn, không tải lên máy chủ.' });
    objectUrl = URL.createObjectURL(file); video.src = objectUrl; video.load();
});
document.getElementById('feedback-form').addEventListener('submit', event => {
    event.preventDefault();
    document.getElementById('feedback-result').textContent = 'Đã ghi nhận góp ý trong phiên xem này. Trang thực hành chưa có máy chủ gửi góp ý.';
    event.target.reset();
});
selectFilm(films[0]);
