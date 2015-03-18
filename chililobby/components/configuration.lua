Configuration = LCS.class{}

-- all configuration attribute changes should use the :Set*Attribute*() and :Get*Attribute*() methods in order to assure proper functionality
function Configuration:init()
	self.scale = 1.2
    self.serverAddress = "localhost"
    --self.serverAddress = "springrts.com"
    self.serverPort = 8200
    
    self.errorColor = "\255\255\0\0"
    self.warningColor = "\255\255\255\0"
    self.successColor = "\255\0\255\0"
	self.selectedColor = "\255\99\184\255"
	self.buttonFocusColor = {0.54,0.72,1,0.3}
	self.buttonSelectedColor = {0.54,0.72,1,0.6}
end

function Configuration:SetScale(scale)
	self.scale = scale
end

function Configuration:GetScale()
	return self.scale
end

function Configuration:GetServerAddress()
    return self.serverAddress
end

function Configuration:GetServerPort()
    return self.serverPort
end

function Configuration:GetErrorColor()
    return self.errorColor
end

function Configuration:GetWarningColor()
    return self.warningColor
end

function Configuration:GetSuccessColor()
    return self.successColor
end

function Configuration:GetSelectedColor()
    return self.selectedColor
end

function Configuration:GetButtonFocusColor()
	return self.buttonFocusColor
end

-- NOTE: this one is in opengl range [0,1]
function Configuration:GetButtonSelectedColor()
	return self.buttonSelectedColor
end

-- shadow the Configuration class with a singleton
Configuration = Configuration()
