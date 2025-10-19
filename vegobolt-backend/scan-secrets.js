#!/usr/bin/env node
/**
 * Secret Leak Scanner for API keys, tokens, and credentials
 * Usage:
 *   node scan-secrets.js [directory]
 * Example:
 *   node scan-secrets.js ./src
 */

const fs = require("fs");
const path = require("path");

const dir = process.argv[2] || ".";
const suspiciousPatterns = [
  /AIza[0-9A-Za-z\\-_]{35}/g, // Google API key
  /(?<=['"\s])(?:secret|token|key|password|api|auth)[-_]?[A-Za-z0-9]*['"\s]*[:=]\s*['"][A-Za-z0-9_\-\/=+]{8,}['"]/gi, // generic key/token pattern
  /-----BEGIN [A-Z ]+ PRIVATE KEY-----/g, // PEM private key
  /mongodb(\+srv)?:\/\/[^ ]+/gi, // MongoDB URI
  /sk_live_[0-9a-zA-Z]{10,}/g, // Stripe live key
  /ghp_[0-9a-zA-Z]{30,}/g, // GitHub personal access token
  /eyJ[a-zA-Z0-9_-]{20,}\.[a-zA-Z0-9_-]{20,}\.[a-zA-Z0-9_-]{20,}/g // JWT-like tokens
];

function scanFile(filePath) {
  const content = fs.readFileSync(filePath, "utf8");
  let findings = [];
  suspiciousPatterns.forEach((pattern) => {
    const matches = content.match(pattern);
    if (matches) {
      findings.push({ pattern: pattern.toString(), matches });
    }
  });
  return findings;
}

function walk(dir) {
  let results = [];
  const list = fs.readdirSync(dir);
  list.forEach((file) => {
    const filePath = path.join(dir, file);
    const stat = fs.statSync(filePath);
    if (stat && stat.isDirectory() && !/node_modules|\.git/.test(filePath)) {
      results = results.concat(walk(filePath));
    } else if (/\.(js|ts|json|env|md|yml|yaml)$/i.test(file)) {
      const findings = scanFile(filePath);
      if (findings.length) {
        results.push({ file: filePath, findings });
      }
    }
  });
  return results;
}

console.log(`🔎 Scanning directory: ${path.resolve(dir)}\n`);
const report = walk(dir);

if (report.length) {
  console.warn("🚨 Potential secrets found!\n");
  report.forEach(({ file, findings }) => {
    console.warn(`⚠️  File: ${file}`);
    findings.forEach((f) =>
      console.warn(`   - Pattern: ${f.pattern}\n   - Matches: ${f.matches.join(", ")}\n`)
    );
  });
  process.exitCode = 1;
} else {
  console.log("✅ No secrets or tokens detected.\n");
}
