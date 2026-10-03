#!/usr/bin/env node
// Desmembra o YAML exportado em tmp/, pois a CLI exige uma coleção em diretório.
const fs = require('node:fs');
const path = require('node:path');
const { createRequire } = require('node:module');
const { execFileSync, spawn } = require('node:child_process');
const { randomUUID } = require('node:crypto');
const root = path.resolve(__dirname, '..');

function findCli() {
  const candidates = [];
  if (process.env.BRUNO_CLI_PATH) candidates.push(process.env.BRUNO_CLI_PATH);
  try { candidates.push(require.resolve('@usebruno/cli/bin/bru.js')); } catch {}
  if (process.env.APPDATA) {
    candidates.push(path.join(process.env.APPDATA, 'npm/node_modules/@usebruno/cli/bin/bru.js'));
  }
  try {
    const locations = execFileSync(process.platform === 'win32' ? 'where.exe' : 'which', ['bru'],
      { encoding: 'utf8', windowsHide: true }).trim().split(/\r?\n/);
    for (const location of locations) {
      if (!fs.existsSync(location)) continue;
      const real = fs.realpathSync(location);
      if (real.endsWith('bru.js')) candidates.push(real);
      candidates.push(path.join(path.dirname(real), 'node_modules/@usebruno/cli/bin/bru.js'));
    }
  } catch {}
  const cli = candidates.find(candidate => fs.existsSync(candidate));
  if (!cli) throw new Error('Instale a CLI: npm install -g @usebruno/cli@4.1.0');
  return path.resolve(cli);
}

async function main() {
  const cli = findCli();
  if (process.argv[2] === '--check-cli') return;
  const yaml = createRequire(cli)('js-yaml');
  const collection = yaml.load(fs.readFileSync(path.join(root, 'ruby_partituras-api.yml'), 'utf8'));
  const baseUrl = (process.argv[2] || 'http://localhost:3000').replace(/\/$/, '');
  const scenario = process.argv[3];
  const selected = scenario ? collection.items.filter(item =>
    item.runtime.variables.some(variable => variable.name === 'scenario' && variable.value === scenario)) : collection.items;
  if (!selected.length) throw new Error(`Cenário desconhecido: ${scenario}`);
  const runId = randomUUID();
  const tempRoot = path.join(root, 'tmp');
  fs.mkdirSync(tempRoot, { recursive: true });
  const directory = fs.mkdtempSync(path.join(tempRoot, 'bruno-collection-'));
  const { items, bundled, extensions, ...config } = collection;

  async function request(method, route) {
    const response = await fetch(`${baseUrl}${route}`, { method, signal: AbortSignal.timeout(10000) });
    if (!response.ok) throw new Error(`${method} ${route}: HTTP ${response.status}`);
    return response.status === 204 ? null : response.json();
  }

  // Limpeza adicional se uma falha de transporte impedir os scripts de testes.
  async function cleanup() {
    const own = item => typeof item.titulo === 'string' && typeof item.autor === 'string' &&
      item.titulo.startsWith(`Bruno ${runId}-`) && item.autor.startsWith(`Autor Bruno ${runId}-`);
    const listing = await request('GET', '/partituras');
    const errors = [];
    for (const item of listing.filter(own)) {
      try { await request('DELETE', `/partituras/${item.id}`); }
      catch (error) { errors.push(error.message); }
    }
    const remaining = (await request('GET', '/partituras')).filter(own);
    if (remaining.length || errors.length) throw new Error(`Limpeza incompleta: ${errors.join('; ')} (${remaining.length} registros)`);
  }

  let exitCode = 1;
  let child;
  let apiAvailable = false;
  const interrupt = () => child?.kill('SIGINT');
  process.on('SIGINT', interrupt);
  process.on('SIGTERM', interrupt);
  try {
    fs.writeFileSync(path.join(directory, 'opencollection.yml'), yaml.dump(config));
    for (const item of selected) {
      fs.writeFileSync(path.join(directory, `${String(item.info.seq).padStart(2, '0')}.yml`), yaml.dump(item));
    }
    const health = await fetch(`${baseUrl}/up`, { signal: AbortSignal.timeout(10000) });
    if (!health.ok) throw new Error(`API indisponível: HTTP ${health.status}`);
    apiAvailable = true;
    console.log(`Bruno: ${selected.length} ${selected.length === 1 ? 'cenário' : 'cenários'} em ${baseUrl}`);
    exitCode = await new Promise((resolve, reject) => {
      child = spawn(process.execPath, [cli, 'run', '--env-var', `baseUrl=${baseUrl}`,
        '--env-var', `runId=${runId}`, '--noproxy', '--reporter-json', path.join(tempRoot, 'bruno-results.json')],
      { cwd: directory, stdio: 'inherit', windowsHide: true });
      child.once('error', reject);
      child.once('exit', code => resolve(code ?? 1));
    });
  } finally {
    if (apiAvailable) {
      try { await cleanup(); }
      catch (error) { console.error(`Falha na limpeza final: ${error.message}`); exitCode = 1; }
    }
    process.removeListener('SIGINT', interrupt);
    process.removeListener('SIGTERM', interrupt);
    // Somente o diretório desta execução, criado por mkdtemp e filho direto de tmp/.
    if (path.dirname(directory) === tempRoot && path.basename(directory).startsWith('bruno-collection-')) {
      fs.rmSync(directory, { recursive: true });
    }
  }
  process.exitCode = exitCode;
}

main().catch(error => { console.error(error.message); process.exitCode = 1; });
