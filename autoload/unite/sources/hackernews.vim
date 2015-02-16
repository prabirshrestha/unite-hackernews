let s:save_cpo = &cpo
set cpo&vim

function! unite#sources#hackernews#define()
    return [s:hackernews_source]
endfunction

let s:hackernews_source = {
    \   'name': 'hackernews',
    \   'description': 'hackernews',
    \   'default_kind': 'uri',
    \   'default_action': { 'uri': 'start' },
    \   'action_table': {}
    \ }

function! unite#sources#hackernews#fetch()
    let dom = webapi#xml#parseURL("http://news.ycombinator.com/rss")
    let items = []
    let i = 1
    for item in dom.find('channel').childNodes('item')
        call add(items, {
            \ 'index': i,
            \ 'title': item.childNode('title').value(),
            \ 'link': item.childNode('link').value(),
            \ 'comments': item.childNode('comments').value(),
            \})
        let i += 1
    endfor
    return items
endfunction

function! s:hackernews_source.gather_candidates(args, context)
    call unite#print_message('Loading hackernews')

    let results = unite#sources#hackernews#fetch()

    let candidates = []
    for news in results
        let candidate = {
            \   'word': news.index . '. ' . news.title,
            \   'action__uri': news.link,
            \   'raw_data': news
            \ }
        call add(candidates, candidate)
    endfor

    return candidates
endfunction

let s:hackernews_source.action_table.comments = {
            \ 'description': 'open comments'
            \}

function! s:hackernews_source.action_table.comments.func(candidate)
    call unite#util#open(a:candidate.raw_data.comments)
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
