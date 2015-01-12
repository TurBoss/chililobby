Configuration = LCS.class{}

-- all configuration attribute changes should use the :Set*Attribute*() and :Get*Attribute*() methods in order to assure proper functionality
function Configuration:init()
	self.scale = 1.2
end

function Configuration:SetScale(scale)
	self.scale = scale
end

function Configuration:GetScale()
	return self.scale
end

-- shadow the Configuration class with a singleton
Configuration = Configuration()