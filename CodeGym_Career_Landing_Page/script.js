'use strict';
const toggle=document.getElementById('menu-toggle');
const menu=document.getElementById('menu');
toggle.addEventListener('click',()=>{const open=menu.classList.toggle('show');toggle.setAttribute('aria-expanded',String(open));});
menu.querySelectorAll('a').forEach(a=>a.addEventListener('click',()=>{menu.classList.remove('show');toggle.setAttribute('aria-expanded','false');}));
document.querySelectorAll('[data-course]').forEach(a=>a.addEventListener('click',()=>{document.getElementById('course').value=a.dataset.course;}));
const form=document.getElementById('consult-form');
form.addEventListener('submit',event=>{
 event.preventDefault();
 const name=document.getElementById('name'),email=document.getElementById('email');
 const errors=[[name,name.value.trim().length<2?'Vui lòng nhập họ và tên.':''],[email,!email.value.trim()||!email.validity.valid?'Vui lòng nhập email hợp lệ.':'']];
 errors.forEach(([field,msg])=>{document.getElementById(field.id+'-error').textContent=msg;field.setAttribute('aria-invalid',String(Boolean(msg)));});
 const first=errors.find(([,msg])=>msg);
 document.getElementById('form-status').textContent=first?'Vui lòng kiểm tra các trường bên trên.':'Thông tin hợp lệ. Đây là form minh họa; hãy dùng nút “Đăng ký tại CodeGym” để liên hệ chính thức.';
 if(first)first[0].focus();
});
