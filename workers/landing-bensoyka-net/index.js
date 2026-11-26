// bensoyka.net landing page: says what the domain is for and points to
// bensoyka.com. The apex is the one public hostname on bensoyka.net (see
// access/apps.tf); everything else on the domain sits behind Access.
//
// Styled like bensoyka.com and keys.bensoyka.com. Small and static, with no
// build step, so unlike the other Workers this one is deployed by Terraform
// (workers-bensoyka-net.tf) rather than from its own repo.

const PAGE = `<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>bensoyka.net — Ben Soyka</title>
<meta name="description" content="Private tools for Ben Soyka. His website is bensoyka.com.">
<meta name="robots" content="noindex">
<link rel="canonical" href="https://bensoyka.com/">
<link rel="preconnect" href="https://fonts.bunny.net">
<link rel="stylesheet" href="https://fonts.bunny.net/css?family=ibm-plex-sans:400,500,700">
<style>
:root { --primary: #507dbc; --secondary: #51b0bd; --light: #f4f9f9; --dark: #04080f; --muted: #4b5563; --line: #e5e7eb; }
* { box-sizing: border-box; }
html { -webkit-text-size-adjust: 100%; }
body { margin: 0; min-height: 100vh; display: grid; place-items: center; padding: 0.75rem;
  background: var(--light); color: var(--dark); font: 16px/1.5 "IBM Plex Sans", sans-serif; }
.card { width: 100%; max-width: 32rem; background: #fff; border: 1px solid var(--line); border-radius: 0.5rem;
  box-shadow: 0 1px 2px rgb(0 0 0 / 0.05); padding: 1.5rem; }
.eyebrow { margin: 0 0 0.25rem; font-weight: 500; }
h1 { font-size: 2.25rem; font-weight: 700; margin: 0 0 0.5rem; line-height: 1.1; padding-bottom: 0.2em;
  border-bottom: 0.065em solid var(--secondary); }
p { margin: 0 0 0.75em; font-size: 1.125rem; }
a { position: relative; color: var(--primary); text-decoration: none; }
a::after { content: ""; position: absolute; bottom: 0; left: 0; width: 0; height: 0.1em; background: var(--primary); transition: width 0.3s ease; }
a:hover::after { width: 100%; }
.btn { display: inline-block; margin-top: 0.5rem; font-weight: 500; padding: 0.625rem 1.25rem; border: 1px solid var(--primary);
  background: #fff; border-radius: 0.5rem; box-shadow: 0 1px 2px rgb(0 0 0 / 0.05); transition: box-shadow 0.2s; }
.btn::after { display: none; }
.btn:hover { box-shadow: 0 10px 15px -3px rgb(0 0 0 / 0.1); }
</style>
</head>
<body>
<main class="card">
  <p class="eyebrow"><a href="https://bensoyka.com">Ben Soyka</a></p>
  <h1>bensoyka.net</h1>
  <p>This domain is home to a few private tools I use myself. There's nothing public here.</p>
  <a class="btn" href="https://bensoyka.com">Go to bensoyka.com</a>
</main>
</body>
</html>
`;

const HEADERS = {
  "Content-Security-Policy":
    "default-src 'none'; style-src 'unsafe-inline' https://fonts.bunny.net; font-src https://fonts.bunny.net; base-uri 'none'; form-action 'none'; frame-ancestors 'none'",
  "X-Content-Type-Options": "nosniff",
  "Referrer-Policy": "strict-origin-when-cross-origin",
  "Strict-Transport-Security": "max-age=31536000",
};

export default {
  fetch(request) {
    const { pathname } = new URL(request.url);
    // Only the page itself; any other path goes to the main site.
    if (pathname !== "/") return Response.redirect("https://bensoyka.com/", 302);
    if (request.method !== "GET" && request.method !== "HEAD") {
      return new Response("Method not allowed", { status: 405, headers: { Allow: "GET, HEAD", ...HEADERS } });
    }
    return new Response(request.method === "HEAD" ? null : PAGE, {
      headers: { "Content-Type": "text/html; charset=utf-8", "Cache-Control": "public, max-age=3600", ...HEADERS },
    });
  },
};
