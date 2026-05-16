#!/usr/bin/env node

const fs = require("node:fs");

const configPath = process.argv[2];
const baseURL = process.env.OMLX_BASE_URL;
const apiKey = process.env.OMLX_API_KEY;

if (!configPath || !baseURL) process.exit(0);

function modelID(value) {
  return typeof value === "string" && value.startsWith("omlx/")
    ? value.slice("omlx/".length)
    : undefined;
}

async function main() {
  const response = await fetch(`${baseURL.replace(/\/$/, "")}/models`, {
    headers: apiKey ? { Authorization: `Bearer ${apiKey}` } : {},
    signal: AbortSignal.timeout(3000),
  });

  if (!response.ok) return;

  const payload = await response.json();
  const data = Array.isArray(payload) ? payload : payload.data;
  const ids = new Set(
    (data || [])
      .map((model) => (typeof model === "string" ? model : model?.id))
      .filter(Boolean),
  );

  if (!ids.size) return;

  const config = JSON.parse(fs.readFileSync(configPath, "utf8"));
  ids.add(modelID(config.model));
  ids.add(modelID(config.small_model));
  ids.delete(undefined);

  const provider = (config.provider ??= {});
  const omlx = (provider.omlx ??= {});
  const previous = omlx.models || {};

  omlx.models = Object.fromEntries(
    [...ids].sort().map((id) => [id, { name: previous[id]?.name || id }]),
  );

  fs.writeFileSync(configPath, `${JSON.stringify(config, null, 2)}\n`);
}

main().catch(() => {});
