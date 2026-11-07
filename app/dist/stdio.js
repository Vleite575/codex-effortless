import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import { createAppServer } from "./server.js";
const server = createAppServer();
await server.connect(new StdioServerTransport());
