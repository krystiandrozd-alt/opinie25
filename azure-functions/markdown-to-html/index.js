const marked = require('marked');
const DOMPurify = require('isomorphic-dompurify');

/**
 * Azure Function: Markdown to HTML Converter
 * Converts Markdown content to sanitized HTML for opinions
 */
module.exports = async function (context, req) {
    context.log('Markdown to HTML conversion function triggered');

    try {
        // Validate request body
        if (!req.body || !req.body.markdown) {
            context.res = {
                status: 400,
                body: {
                    error: "Missing 'markdown' field in request body"
                }
            };
            return;
        }

        const markdown = req.body.markdown;
        const options = req.body.options || {};

        // Configure marked options
        marked.setOptions({
            gfm: true,              // GitHub Flavored Markdown
            breaks: true,           // Convert \n to <br>
            smartLists: true,       // Use smarter list behavior
            smartypants: false,     // Don't use typographic punctuation
            ...options.markedOptions
        });

        // Convert Markdown to HTML
        let html = marked.parse(markdown);

        // Sanitize HTML to prevent XSS attacks
        const cleanHtml = DOMPurify.sanitize(html, {
            ALLOWED_TAGS: [
                'h1', 'h2', 'h3', 'h4', 'h5', 'h6',
                'p', 'br', 'hr',
                'strong', 'em', 'u', 's', 'mark',
                'ul', 'ol', 'li',
                'blockquote', 'pre', 'code',
                'table', 'thead', 'tbody', 'tr', 'th', 'td',
                'a', 'img'
            ],
            ALLOWED_ATTR: ['href', 'src', 'alt', 'title', 'class']
        });

        // Calculate statistics
        const stats = {
            characterCount: markdown.length,
            wordCount: markdown.split(/\s+/).filter(word => word.length > 0).length,
            htmlLength: cleanHtml.length
        };

        // Return success response
        context.res = {
            status: 200,
            headers: {
                'Content-Type': 'application/json'
            },
            body: {
                success: true,
                html: cleanHtml,
                stats: stats,
                timestamp: new Date().toISOString()
            }
        };

    } catch (error) {
        context.log.error('Error converting markdown:', error);

        context.res = {
            status: 500,
            body: {
                error: "Failed to convert markdown to HTML",
                message: error.message
            }
        };
    }
};
