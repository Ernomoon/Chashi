// Упаковка «Ночной чайной»: Rust-exe (Tauri) + NSIS-установщик. Создатель — Ernomoon.
import fs from 'node:fs';
import path from 'node:path';
import { execSync } from 'node:child_process';

const root = path.resolve(path.dirname(new URL(import.meta.url).pathname.replace(/^\/([A-Za-z]:)/, '$1')), '..');
process.chdir(root);
const run = (cmd) => { console.log('> ' + cmd); execSync(cmd, { stdio: 'inherit' }); };

// Версия должна совпадать везде — иначе проверка обновлений будет врать.
const pkg = JSON.parse(fs.readFileSync('package.json', 'utf8')).version;
const conf = JSON.parse(fs.readFileSync('src-tauri/tauri.conf.json', 'utf8')).version;
const cargo = (fs.readFileSync('src-tauri/Cargo.toml', 'utf8').match(/^version = "([\d.]+)"/m) || [])[1];
const html = (fs.readFileSync('resources/index.html', 'utf8').match(/VERSION='([\d.]+)'/) || [])[1];
if (new Set([pkg, conf, cargo, html]).size !== 1) {
  console.error(`Версии не совпадают: package.json=${pkg}, tauri.conf.json=${conf}, Cargo.toml=${cargo}, index.html=${html}`);
  process.exit(1);
}
const v = pkg;
const exe = process.env.CHASHI_EXE || 'src-tauri/target/release/chashi.exe';
if (!fs.existsSync(exe)) { console.error('Нет ' + exe + ' — сначала cargo build --release'); process.exit(1); }

fs.rmSync('dist', { recursive: true, force: true });
fs.mkdirSync('dist');
fs.copyFileSync(exe, 'dist/Chashi.exe');
fs.copyFileSync(exe, `dist/Chashi-Portable-${v}.exe`);
const [a, b, c] = v.split('.');
run(`"${process.env.MAKENSIS || 'makensis'}" -V2 -DVERSION=${v} -DVERSION4=${a}.${b}.${c}.0 installer/chashi.nsi`);
for (const f of fs.readdirSync('dist')) console.log(`${f}  ${(fs.statSync('dist/' + f).size / 1048576).toFixed(2)} MB`);
