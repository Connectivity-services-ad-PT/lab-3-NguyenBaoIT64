#!/usr/bin/env node
/**
 * Start all Prism mock servers in parallel and wait for them to be ready
 */

const { spawn } = require('child_process');
const http = require('http');
const path = require('path');

const SERVERS = [
  { port: 4020, name: 'access-gate', script: 'mock:access-gate' },
  { port: 4010, name: 'iot-ingestion', script: 'mock:iot' },
  { port: 4011, name: 'ai-vision', script: 'mock:vision' }
];

const MAX_RETRIES = 60; // 60 * 1 second = 60 seconds
const RETRY_DELAY = 1000; // 1 second

async function checkHealth(port) {
  return new Promise((resolve) => {
    const req = http.get(`http://localhost:${port}/health`, (res) => {
      resolve(res.statusCode === 200);
      res.on('data', () => {});
    });
    req.on('error', () => resolve(false));
    req.setTimeout(1000);
  });
}

async function waitForServer(port, name, maxRetries = MAX_RETRIES) {
  for (let i = 0; i < maxRetries; i++) {
    const healthy = await checkHealth(port);
    if (healthy) {
      console.log(`✓ ${name} mock server ready on port ${port}`);
      return true;
    }
    if (i % 10 === 0) {
      console.log(`  Waiting for ${name} on port ${port}... (attempt ${i + 1}/${maxRetries})`);
    }
    await new Promise(resolve => setTimeout(resolve, RETRY_DELAY));
  }
  console.error(`✗ ${name} mock server on port ${port} failed to start after ${maxRetries}s`);
  return false;
}

async function startServers() {
  const processes = [];
  const startPromises = [];

  console.log('Starting Prism mock servers...\n');

  // Start all servers
  for (const server of SERVERS) {
    console.log(`Starting ${server.name} on port ${server.port}...`);
    
    const child = spawn('npm', ['run', server.script], {
      cwd: process.cwd(),
      stdio: ['ignore', 'pipe', 'pipe'],
      detached: false,
      shell: true
    });

    // Log output
    child.stdout.on('data', (data) => {
      if (data.toString().includes('listening') || data.toString().includes('started')) {
        console.log(`  [${server.name}] ${data.toString().trim()}`);
      }
    });

    child.stderr.on('data', (data) => {
      if (!data.toString().includes('DEP0176')) { // Ignore deprecation warnings
        console.log(`  [${server.name}] ${data.toString().trim()}`);
      }
    });

    child.on('error', (err) => {
      console.error(`Failed to start ${server.name}: ${err.message}`);
    });

    processes.push({ server, child });
    startPromises.push(waitForServer(server.port, server.name));
  }

  // Wait for all servers
  console.log('\nWaiting for servers to be ready...\n');
  const results = await Promise.all(startPromises);

  // Check results
  const allReady = results.every(r => r);
  
  if (!allReady) {
    console.error('\n⚠️  Some servers failed to start, but continuing with tests...\n');
    // Kill all processes
    processes.forEach(({ child }) => {
      try {
        process.kill(-child.pid);
      } catch (e) {}
    });
    process.exit(1);
  }

  console.log('\n✓ All mock servers are ready!\n');
  
  // Keep processes alive and clean up on exit
  process.on('exit', () => {
    processes.forEach(({ child }) => {
      try {
        process.kill(-child.pid);
      } catch (e) {}
    });
  });

  process.on('SIGINT', () => {
    console.log('\nShutting down mock servers...');
    processes.forEach(({ child }) => {
      try {
        process.kill(-child.pid);
      } catch (e) {}
    });
    process.exit(0);
  });
}

startServers().catch(err => {
  console.error('Failed to start servers:', err);
  process.exit(1);
});
