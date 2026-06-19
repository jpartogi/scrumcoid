module ResourcesHelper
  def resource_tag_filter_class(tag, current_tag = nil)
    active = current_tag.present? && Resource.normalize_tag(tag) == Resource.normalize_tag(current_tag)
    resource_tag_filter_pill_class(active: active)
  end

  def resource_all_tags_filter_class(current_tag = nil)
    resource_tag_filter_pill_class(active: current_tag.blank?)
  end

  def resource_hero_tag_filter_class(tag, current_tag = nil)
    active = current_tag.present? && Resource.normalize_tag(tag) == Resource.normalize_tag(current_tag)
    resource_hero_tag_filter_pill_class(active: active)
  end

  def resource_hero_all_tags_filter_class(current_tag = nil)
    resource_hero_tag_filter_pill_class(active: current_tag.blank?)
  end

  def resource_tag_link_class
    "inline-flex items-center rounded-xl bg-slate-50 border border-slate-200/60 px-3 py-1.5 text-xs font-bold text-slate-600 hover:border-indigo-300 hover:text-indigo-600 hover:bg-indigo-50/10 transition-all"
  end

  def resource_tag_link_class_on_dark
    "inline-flex items-center rounded-xl bg-white/5 border border-white/10 px-3 py-1.5 text-xs font-bold text-slate-300 hover:border-teal-400/40 hover:text-teal-300 transition-all"
  end

  def resource_price_badge_class(resource)
    if resource.free?
      "bg-emerald-50 text-emerald-700 ring-emerald-600/20"
    else
      "bg-indigo-50 text-indigo-700 ring-indigo-600/20"
    end
  end

  private

  def resource_tag_filter_pill_class(active:)
    base = "inline-flex items-center rounded-full px-4 py-2 text-sm font-bold transition-all"
    if active
      "#{base} bg-indigo-600 text-white shadow-md shadow-indigo-500/20"
    else
      "#{base} bg-white text-slate-600 border border-slate-200/80 hover:border-indigo-300 hover:text-indigo-600"
    end
  end

  def resource_hero_tag_filter_pill_class(active:)
    base = "inline-flex items-center gap-1 rounded-full px-4 py-2 text-sm font-bold transition-all backdrop-blur-sm"
    if active
      "#{base} bg-gradient-to-r from-teal-500/30 to-indigo-500/30 text-white ring-1 ring-inset ring-teal-400/40 shadow-[0_0_20px_rgba(20,184,166,0.15)]"
    else
      "#{base} bg-white/10 text-slate-300 ring-1 ring-inset ring-white/15 hover:bg-white/15 hover:text-white hover:ring-white/25"
    end
  end
end