Jekyll::Hooks.register :site, :post_read do |site|
  # 如果不是本地开发环境，则过滤掉特定的文章
  if Jekyll.env != "development"
    site.posts.docs.reject! do |post|
      # 检查文章的 tags 数组里是否包含你指定的标签（例如 "dev-only"）
      post.data['tags']&.include?('unpublish')
    end
  end
end