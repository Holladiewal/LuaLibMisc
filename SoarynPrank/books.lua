local data = {}
rednet.open("right")
p = peripheral.wrap("bottom")

function checkSlots(id)
   data = {}
   local slot
   local name
   local slots = p.getAllStacks()
   for i,j in pairs(slots) do
      slot = i
      name = j["destination"]
--      print(name)
      data[slot]=name
   end
   rednet.send(id,"done")
end

function removeSlot(slot)
   p.pushItem("up", slot, 1)
   rs.setOutput("left", true)
   sleep(1)
   rs.setOutput("left", false)
end

function book(slot,id)
   p.pushItem("up", slot, 1)
   turtle.select(1)
   turtle.drop()
   sleep(5)
   getBook()
   turtle.select(1)
   turtle.dropDown()
   rednet.send(tonumber(id), "done")
end

function getBook()
   turtle.suck()
end

function getNames(id)
   local nameTbl = textutils.serialize(data)
   rednet.send(tonumber(id), nameTbl)
end

while true do
   local id, msg, dis = rednet.receive()
   local newmsg = string.match(msg, "%a+")
--   print(msg)
   if newmsg == "checkSlots" then
     checkSlots(id) 
   elseif newmsg == "getNames" then
     getNames(id)
   elseif newmsg == "remove" then
     removeSlot(tonumber(string.match(msg, "%d+")))
     rednet.send(id,"done")
   elseif newmsg == "books" then
     slot = string.match(msg, "%d+")
     book(tonumber(slot), id)
   end
end