LoginWindow = LCS.class{}

function LoginWindow:init()
    self.lblInstructions = Label:New {
        x = 1,
        width = 100,
        y = 20,
        height = 20,
        caption = "Connect to the Spring lobby server:",
    }

    self.lblUsername = Label:New {
        x = 1,
        width = 100,
        y = 50,
        height = 20,
        caption = "Username: ",
    }
    self.ebUsername = EditBox:New {
        x = 110,
        width = 120,
        y = 50,
        height = 20,
        text = "",
    }

    self.lblPassword = Label:New {
        x = 1,
        width = 100,
        y = 75,
        height = 20,
        caption = "Password: ",
    }
    self.ebPassword = EditBox:New {
        x = 110,
        width = 120,
        y = 75,
        height = 20,
        text = "",
        passwordInput = true,
        OnKeyPress = {
            function(obj, key, mods, ...)
                if key == Spring.GetKeyCode("enter") or 
                    key == Spring.GetKeyCode("numpad_enter") then
                    self:tryLogin()
                end
            end
        },
    }
    self.btnLogin = Button:New {
        x = 1,
        width = 80,
        bottom = 1,
        height = 40,
        caption = "Login",
        OnClick = {
            function()
                self:tryLogin()
            end
        },
    }

    self.window = Window:New {
        x = 700,
        y = 300,
        width = 265,
        height = 220,
        caption = "Login",
        resizable = false,
        children = {
            self.lblInstructions,
            self.lblUsername,
            self.lblPassword,
            self.ebUsername,
            self.ebPassword,
            self.btnLogin
        },
        parent = screen0,
    }
end

function LoginWindow:tryLogin()
    username = self.ebUsername.text
    password = self.ebPassword.text
    if username == '' or password == '' then
        return
    end
    lobby:Initialize()

    lobby:Connect("localhost", "8200")
    lobby:Login(username, password, 3)

    local playWindow = PlayWindow()
    local chatWindows = ChatWindows()
    self.window:Dispose()
end
