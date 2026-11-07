import { createServer } from "node:http";
import { readFileSync } from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";
import { registerAppResource, registerAppTool, RESOURCE_MIME_TYPE, } from "@modelcontextprotocol/ext-apps/server";
import { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import { StreamableHTTPServerTransport } from "@modelcontextprotocol/sdk/server/streamableHttp.js";
import { z } from "zod";
const __dirname = path.dirname(fileURLToPath(import.meta.url));
const ROOT_DIR = path.resolve(__dirname, "..");
export const WIDGET_URI = "ui://widget/main-v1.html";
export const WIDGET_HTML = readFileSync(path.join(ROOT_DIR, "public", "widget.html"), "utf8");
export function createAppServer() {
    const server = new McpServer({
        name: "codex-effortless",
        version: "0.1.0",
    });
    registerAppResource(server, "main-widget", WIDGET_URI, {}, async () => ({
        contents: [
            {
                uri: WIDGET_URI,
                mimeType: RESOURCE_MIME_TYPE,
                text: WIDGET_HTML,
                _meta: {
                    ui: {
                        prefersBorder: true,
                        csp: {
                            connectDomains: [],
                            resourceDomains: [],
                        },
                    },
                    "openai/widgetDescription": "Codex Effortless starter widget rendered by the MCP server.",
                },
            },
        ],
    }));
    registerAppTool(server, "show_effortless", {
        title: "Codex Effortless",
        description: "Use this when the user wants to see the Codex Effortless status bar: automatic effort, current model, context usage, compact, and settings.",
        inputSchema: {
            message: z
                .string()
                .optional()
                .describe("Optional message to show inside the widget."),
        },
        annotations: {
            readOnlyHint: true,
            destructiveHint: false,
            openWorldHint: false,
            idempotentHint: true,
        },
        _meta: {
            ui: { resourceUri: WIDGET_URI },
            "openai/toolInvocation/invoking": "Loading Codex Effortless",
            "openai/toolInvocation/invoked": "Codex Effortless ready",
        },
    }, async ({ message }) => {
        const resolvedMessage = message?.trim() || "Pronto para escolher o esforço da próxima tarefa.";
        return {
            content: [
                {
                    type: "text",
                    text: "Rendered the Codex Effortless starter widget.",
                },
            ],
            structuredContent: {
                headline: "Codex Effortless",
                message: resolvedMessage,
                effort: "medium",
                model: "Current",
                context: 20,
                auto: true,
                why: resolvedMessage,
            },
            _meta: {
                "openai/outputTemplate": WIDGET_URI,
            },
        };
    });
    registerAppTool(server, "set_effortless_mode", {
        title: "Set automatic effort",
        description: "Use this when the status bar toggle changes automatic effort selection.",
        inputSchema: { auto: z.boolean() },
        annotations: { readOnlyHint: false, destructiveHint: false, openWorldHint: false, idempotentHint: true },
        _meta: { ui: { resourceUri: WIDGET_URI } },
    }, async ({ auto }) => ({
        content: [{ type: "text", text: auto ? "Automatic effort enabled." : "Automatic effort paused." }],
        structuredContent: { effort: auto ? "medium" : "manual", model: "Current", context: 20, auto, why: auto ? "Auto ativo" : "Auto pausado" },
    }));
    return server;
}
const port = Number(process.env.PORT ?? "8787");
const MCP_PATH = "/mcp";
if (process.env.CODEX_EFFORTLESS_TRANSPORT !== "stdio")
    createServer(async (req, res) => {
        if (!req.url) {
            res.writeHead(400).end("Missing URL");
            return;
        }
        const url = new URL(req.url, "http://" + (req.headers.host ?? "localhost"));
        const isMcpRoute = url.pathname === MCP_PATH || url.pathname.startsWith(MCP_PATH + "/");
        if (req.method === "OPTIONS" && isMcpRoute) {
            res.writeHead(204, {
                "Access-Control-Allow-Origin": "*",
                "Access-Control-Allow-Methods": "POST, GET, DELETE, OPTIONS",
                "Access-Control-Allow-Headers": "content-type, mcp-session-id",
                "Access-Control-Expose-Headers": "Mcp-Session-Id",
            });
            res.end();
            return;
        }
        if (req.method === "GET" && url.pathname === "/") {
            res.writeHead(200, { "content-type": "text/plain" }).end("Codex Effortless MCP server");
            return;
        }
        const transportMethods = new Set(["GET", "POST", "DELETE"]);
        if (isMcpRoute && req.method && transportMethods.has(req.method)) {
            res.setHeader("Access-Control-Allow-Origin", "*");
            res.setHeader("Access-Control-Expose-Headers", "Mcp-Session-Id");
            const server = createAppServer();
            const transport = new StreamableHTTPServerTransport({
                sessionIdGenerator: undefined,
                enableJsonResponse: true,
            });
            res.on("close", () => {
                transport.close();
                server.close();
            });
            try {
                await server.connect(transport);
                await transport.handleRequest(req, res);
            }
            catch (error) {
                console.error("Failed to handle MCP request:", error);
                if (!res.headersSent) {
                    res.writeHead(500).end("Internal server error");
                }
            }
            return;
        }
        res.writeHead(404).end("Not Found");
    }).listen(port, () => {
        console.log("Codex Effortless MCP server listening on http://localhost:" + port + MCP_PATH);
    });
