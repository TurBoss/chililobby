Background = LCS.class{}

function Background:init()
	self.backgroundImage = CHILI_LOBBY_IMG_DIR .. "default_background.png"
	self.drawBackground = true
end

function Background:DrawScreen()
	if self.drawBackground then
		gl.PushMatrix()
			gl.Texture(self.backgroundImage)
			
			gl.BeginEnd(GL.QUADS,
				function()
					local w, h = Spring.GetScreenGeometry()
					
					gl.TexCoord(0, 1)
					gl.Vertex(0, 0)
					
					gl.TexCoord(0, 0)
					gl.Vertex(0, h)
						
					gl.TexCoord(1, 0)
					gl.Vertex(w, h)
					
					gl.TexCoord(1, 1)
					gl.Vertex(w, 0)
				end
			)
		gl.PopMatrix()
	end
end

function Background:SetBackgroundImagePath(newImagePath)
	self.backgroundImage = newImagePath
end

function Background:Enable()
	self.drawBackground = true
end

function Background:Disable()
	self.drawBackground = false
end