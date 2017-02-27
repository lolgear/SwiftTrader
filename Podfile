platform :ios, '9.0'
source 'https://github.com/CocoaPods/Specs.git'

def datalayer
	# database management
    pod 'MagicalRecord', git:'https://github.com/magicalpanda/MagicalRecord.git' ,branch: 'release/3.0'
end

def networklayer
	# network
	pod 'Alamofire'
end

def uikit
	# well-styled progress hud
	# pod 'MBProgressHUD', '~> 0.9.1'
	# easy autolayout
	pod 'SnapKit'
	# well-styled notifications
	pod 'SwiftMessages'
end

def security
end

def protocols
end

def utilities
	# logging
	pod 'CocoaLumberjack/Swift'
end

def patterns
end

def services
	# statistics
	# pod 'Fabric'
	# pod 'Crashlytics'
	# # rating
end

def infoPlist
end

def appName
	'SwiftTrader'
end

def networkLayerFramework
	'Network'
end

def databaseLayerFramework
	'Database'
end

target networkLayerFramework do
	use_frameworks!
	networklayer
end

target databaseLayerFramework do
	use_frameworks!
	datalayer
end

target appName do
	# inhibit_all_warnings!
	use_frameworks!
	datalayer
	networklayer
	uikit
	security
	protocols
	utilities
	patterns
	services
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = '3.0'
        end
    end
end
