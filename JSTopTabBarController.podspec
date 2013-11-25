Pod::Spec.new do |s|

  s.name         = "JSTopTabBarController"
  s.version      = "1.0"
  s.summary      = "A new different interface for navigating around your iOS app."

  s.description  = <<-DESC
                   A longer description of JSTopTabBarController in Markdown format.

                   * Think: Why did you write this? What is the focus? What does it do?
                   * CocoaPods will be using this to generate tags, and improve search results.
                   * Try to keep it short, snappy and to the point.
                   * Finally, don't worry about the indent, CocoaPods strips it!
                   DESC

  s.homepage     = "https://github.com/jrmsklar/JSTopTabBarController"

  s.license      = { :type => 'MIT', :file => 'LICENSE' }

  s.author       = { "Josh Sklar" => "jrmsklar@gmail.com" }

  s.platform     = :ios, '6.0'

  s.source       = { :git => "https://github.com/jrmsklar/JSTopTabBarController.git", :tag => '1.0' }

  s.source_files  = 'JSTopTabBar/JSTopTabBarController.{h,m}'
  s.exclude_files = 'Classes/Exclude'

  s.resources = 'JSTopTabBar/*@2x.png'

  s.framework  = 'QuartzCore'

  s.requires_arc = true


end
