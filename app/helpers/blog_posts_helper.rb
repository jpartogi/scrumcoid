module BlogPostsHelper
  # Tags on light backgrounds (card on index, related posts on show)
  def blog_post_tag_link_class
    "inline-flex items-center gap-1 rounded-md bg-indigo-50 px-2.5 py-1 text-[11px] font-bold tracking-wide text-indigo-600 ring-1 ring-inset ring-indigo-200 hover:bg-indigo-100 hover:text-indigo-700 hover:ring-indigo-300 hover:-translate-y-px transition-all duration-150 select-none"
  end

  # Tags rendered on the dark hero in show page
  def blog_post_tag_link_class_on_dark
    "inline-flex items-center gap-1 rounded-md bg-white/10 px-3 py-1.5 text-xs font-bold tracking-wide text-teal-300 ring-1 ring-inset ring-white/20 hover:bg-white/15 hover:text-white hover:ring-white/30 hover:-translate-y-px transition-all duration-150 backdrop-blur-sm select-none"
  end

  # Tag filter pills on the index page filter bar
  def blog_post_tag_filter_class(tag, current_tag = nil)
    active = current_tag.present? && BlogPost.normalize_tag(tag) == BlogPost.normalize_tag(current_tag)
    blog_post_tag_filter_pill_class(active: active)
  end

  def blog_post_all_tags_filter_class(current_tag = nil)
    blog_post_tag_filter_pill_class(active: current_tag.blank?)
  end

  def blog_post_tag_filter_pill_class(active:)
    if active
      "inline-flex items-center gap-1.5 rounded-lg bg-gradient-to-r from-indigo-600 to-violet-600 px-4 py-1.5 text-xs font-bold text-white shadow-md shadow-indigo-500/20 ring-1 ring-inset ring-white/10 scale-[1.03] transition-all duration-150"
    else
      "inline-flex items-center gap-1.5 rounded-lg bg-slate-50 px-4 py-1.5 text-xs font-bold text-slate-600 ring-1 ring-inset ring-slate-200 hover:bg-indigo-50 hover:text-indigo-700 hover:ring-indigo-200 hover:-translate-y-px transition-all duration-150"
    end
  end
end
