local function InitializeGUI()
    return {
        display = term,
        elements = {},
        bkgcol = colors.black,
        fgrcol = colors.white,
        Clear = function()
            self.display.setBackgroundColor(self.bkgcol)
            self.display.setTextColor(self.fgrcol)
            self.display.clear()
        end,
        CreateElement = function(tag, x, y, w, h, bkgcol, fgrcol)
            local e = {
                tag = tag,
                x = x,
                y = y,
                w = w,
                h = h,
                bkgcol = bkgcol,
                fgrcol = fgrcol,
                WriteAt = function(x, y, str, bkgcol, fgrcol)
                    self.display.setTextColor(self.fgrcol)
                    self.display.setCursorPos(x + 1, y + 1);
                    self.display.write(str);
                end,
            }
            table.insert(self.elements, e);
            return e;
        end
    }
end

GUI = InitializeGUI();
