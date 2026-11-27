// Сборка «Ночной чайной» для Windows: Neutralino-exe с иконкой + NSIS-установщик.
// Работает и на Linux (CI), и на Windows. Создатель — Ernomoon.
import fs from 'node:fs';
import path from 'node:path';
import { execSync } from 'node:child_process';
import * as ResEdit from 'resedit';
import * as PE from 'pe-library';

const root = path.resolve(path.dirname(new URL(import.meta.url).pathname.replace(/^\/([A-Za-z]:)/, '$1')), '..');
process.chdir(root);
const run = (cmd) => { console.log('> ' + cmd); execSync(cmd, { stdio: 'inherit' }); };

// 1. Версия должна совпадать везде — иначе проверка обновлений будет врать.
const pkg = JSON.parse(fs.readFileSync('package.json', 'utf8'));
const cfg = JSON.parse(fs.readFileSync('neutralino.config.json', 'utf8'));
const html = fs.readFileSync('resources/index.html', 'utf8');
const htmlVer = (html.match(/VERSION='([\d.]+)'/) || [])[1];
const v = pkg.version;
if (cfg.version !== v || htmlVer !== v) {
  console.error(`Версии не совпадают: package.json=${v}, neutralino.config.json=${cfg.version}, index.html=${htmlVer}`);
  process.exit(1);
}
const [ma, mi, pa] = v.split('.').map(Number);

// 2. Бинарники Neutralino
const base = 'bin/neutralino-win_x64.exe';
if (!fs.existsSync(base)) run('npx neu update');

// 3. Иконка и сведения о файле прямо в exe (до встраивания ресурсов)
const exe = PE.NtExecutable.from(fs.readFileSync(base), { ignoreCert: true });
const res = PE.NtExecutableResource.from(exe);
const ico = ResEdit.Data.IconFile.from(fs.readFileSync('build/icon.ico'));
const groups = ResEdit.Resource.IconGroupEntry.fromEntries(res.entries);
const gid = groups.length ? groups[0].id : 1, glang = groups.length ? groups[0].lang : 1033;
ResEdit.Resource.IconGroupEntry.replaceIconsForResource(res.entries, gid, glang, ico.icons.map((i) => i.data));
const vi = ResEdit.Resource.VersionInfo.fromEntries(res.entries)[0] || ResEdit.Resource.VersionInfo.createEmpty();
vi.setFileVersion(ma, mi, pa, 0);
vi.setProductVersion(ma, mi, pa, 0);
const langs = vi.getAllLanguagesForStringValues();
if (!langs.length) langs.push({ lang: 1033, codepage: 1200 });
for (const l of langs) {
  vi.setStringValues(l, {
    FileDescription: 'Ночная чайная',
    ProductName: 'Ночная чайная',
    CompanyName: 'Ernomoon',
    LegalCopyright: '© 2026 Ernomoon',
    OriginalFilename: 'Chashi.exe',
    InternalName: 'Chashi',
    FileVersion: v,
    ProductVersion: v,
  });
}
vi.outputToResourceEntries(res.entries);
res.outputResource(exe);
fs.writeFileSync(base, Buffer.from(exe.generate()));
console.log('Иконка и сведения о версии записаны в exe');

// 4. Один exe со встроенными ресурсами
fs.rmSync('dist', { recursive: true, force: true });
run('npx neu build --release --embed-resources');
const built = 'dist/chashi/chashi-win_x64.exe';
fs.copyFileSync(built, 'dist/Chashi.exe');
fs.copyFileSync(built, `dist/Chashi-Portable-${v}.exe`);

// 5. Установщик
const makensis = process.env.MAKENSIS || 'makensis';
try {
  run(`"${makensis}" -V2 -DVERSION=${v} -DVERSION4=${ma}.${mi}.${pa}.0 installer/chashi.nsi`);
} catch (e) {
  console.error('makensis не найден или упал — установщик не собран');
  process.exit(1);
}
for (const f of fs.readdirSync('dist')) {
  const p = path.join('dist', f);
  if (fs.statSync(p).isFile()) console.log(`${f}  ${(fs.statSync(p).size / 1048576).toFixed(2)} MB`);
}
