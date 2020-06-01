<div id="content-wrap">
  <div class="wrapper">
    <div class="inner">
      {{ partial('partial/post', {post: page}) }}
      <aside id="article-toc" role="navigation">
            <div id="article-toc-inner">
              {{ partial('partial/carbonads') }}
              <strong class="sidebar-title">{{ __('page.contents') }}</strong>
              {{ toc(page.content, {list_number: false}) }}
              <a href="#" id="article-toc-top">{{ __('page.back_to_top') }}</a>
            </div>
          </aside>
    </div>
  </div>
</div>

