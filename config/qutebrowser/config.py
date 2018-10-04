c.downloads.location.directory = '~/downloads/qutebrowser/'

c.fonts.web.size.default = 10

c.fonts.web.size.default_fixed = 10

# ignore-case (IgnoreCase):
#     Whether to find text on a page case-insensitively.
#         true: Search case-insensitively
#         false: Search case-sensitively
#         smart: Search case-sensitively if there are capital chars
#     Default: smart
c.search.ignore_case = 'smart'

# Definitions of search engines which can be used via the address bar.
# The searchengine named `DEFAULT` is used when `general -> auto-search`
# is true and something else than a URL was entered to be opened. Other
# search engines can be used by prepending the search engine name to the
# search term, e.g. `:open google qutebrowser`. The string `{}` will be
# replaced by the search term, use `{{` and `}}` for literal `{`/`}`
# signs.
c.url.searchengines = dict(
	DEFAULT='https://duckduckgo.com/?q={}',
	google='https://www.google.com/search?q={}',
	wiki='https://en.wikipedia.org/wiki/{}',
	voidwiki='https://wiki.voidlinux.eu/index.php?search={}&title=Special%3ASearch&go=Go',
	voidforum='https://forum.voidlinux.eu/search?q={}',
)

config.bind('<', 'tab-move -')
config.bind('>', 'tab-move +')
