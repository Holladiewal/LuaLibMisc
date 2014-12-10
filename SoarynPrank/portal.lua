os.loadAPI("button")
m = peripheral.wrap("left")
m.clear()
rednet.open("bottom")
local page = 1
local pages = 0
local names = {}
local turtles = {}
local remove = false

function fillTurtles()
   turtles[1] = 47
--   turtles[2] = 114
--   turtles[3] = 117
end

function fillTable()
   m.clear()
   button.clearTable()
   local totalrows = 0
   local numNames = 0
   local col = 2
   local row = 12
   local countRow = 1
   local currName = 0
   local npp = 12 --names per page
   for turt, data in pairs(names) do
      for i,j in pairs(data) do
         totalrows = totalrows+1
      end
   end
   pages = math.ceil(totalrows/npp)
   print(totalrows)
   for turt, data in pairs(names) do
      currName = 0
      for slot, name in pairs(data) do
       currName = currName + 1
       if currName > npp*(page-1) and currName < npp*page+1 then
         row = 4+(countRow)
         names[turt][slot] = string.sub(name, 0, 17)
         button.setTable(string.sub(name, 0, 17), runStuff, turt..":"..slot, col, col+17 , row, row)
         if col == 21 then 
           col = 2 
           countRow = countRow + 2
         else 
           col = col+19 
         end
       end
      end
   end
   button.setTable("Next Page", nextPage, "", 21, 38, 1, 1)
   button.setTable("Prev Page", prevPage, "", 2, 19, 1, 1)
   button.setTable("Refresh", checkNames, "", 21, 38, 19, 19)
   button.setTable("Remove Book", removeIt, "", 2, 19, 19, 19)
   button.label(15,3, "Page: "..tostring(page).." of "..tostring(pages))
   button.screen()
end      

function nextPage()
   if page+1 <= pages then page = page+1 end
   fillTable()
end

function prevPage()
   if page-1 >= 1 then page = page-1 end
   fillTable()
end   
                           
function getNames()
   names = {}
   for x, y in pairs(turtles) do
      names[y] = {}
      rednet.send(y, "getNames")
      local id, msg, dist = rednet.receive(2)
--      print(msg)
      names[y] = textutils.unserialize(msg)
   end
end

function removeIt()
   remove = not remove
--   print(remove)
   button.toggleButton("Remove Book")
end

function runStuff(info)
   if remove == true then
      removeBook(info)
   else
      openPortal(info)
   end      
end

function removeBook(info)
   local turt, slot = string.match(info, "(%d+):(%d+)")
   button.toggleButton(names[tonumber(turt)][tonumber(slot)])
   data = "remove"..tostring(slot)
   rednet.send(tonumber(turt), data)
   rednet.receive()
   button.toggleButton(names[tonumber(turt)][tonumber(slot)])
   remove=false
   button.toggleButton("Remove Book")
--   sleep(1)
   checkNames()
end   

function openPortal(info)
   local turt,slot = string.match(info, "(%d+):(%d+)")
--   print(names[tonumber(turt)][tonumber(slot)])
   button.toggleButton(names[tonumber(turt)][tonumber(slot)])
   print(names[tonumber(turt)][tonumber(slot)])
   data = "books"..tostring(slot)
   rednet.send(tonumber(turt), data)
   rednet.receive()
   button.toggleButton(names[tonumber(turt)][tonumber(slot)])
end

function checkNames()
   button.flash("Refresh")
   for num, turt in pairs(turtles) do
     rednet.send(turt, "checkSlots")
     msg = ""
     while msg ~= "done" do
       id, msg, dist = rednet.receive()
       if msg == "getName" then
          m.clear()
          m.setCursorPos(5, 12)
          m.write("New book detected.")
          m.setCursorPos(5, 14)
          m.write("Please enter the name")
          m.setCursorPos(5, 16)
          m.write("On the computer")
          m.setCursorPos(5, 18)
          m.write("<<----")
          term.clear()
          term.write("Please enter a name for the new book: ")
          name = read()
          rednet.send(id, name)
       end
     end
   end
   getNames()
   fillTable()
end

function getClick()
   event, side, x,y = os.pullEvent()
   if event == "monitor_touch" then
      button.checkxy(x,y)
   elseif event == "redstone" then
      print("redstone")
      sleep(5)
      checkNames()      
   end
end

fillTurtles()
fillTable()
checkNames()


while true do
   getClick()
--   checkNames()
end