local helperfunctions = {}

function helperfunctions.deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[helperfunctions.deepcopy(orig_key)] = helperfunctions.deepcopy(orig_value)
        end
        setmetatable(copy, helperfunctions.deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
 end
 
 function helperfunctions.printGrid(grid)
    for i=1,#grid do
        local finalLine = ""
        for j=1,#grid[1] do
            finalLine = finalLine .. grid[i][j] .. " "
      end
        print(finalLine)
    end
    print("====")
 end
 
 function helperfunctions.printArray(arr)
     local final_line = ""
     for i=1, #arr do
         final_line = final_line .. " " .. arr[i]
     end
     print(final_line)
     print("===")
 end
 
 function helperfunctions.shuffle(tbl)
    local size = #tbl
    for i = size, 1, -1 do
      local rand = math.random(i)
      tbl[i], tbl[rand] = tbl[rand], tbl[i]
    end
    return tbl
  end

return helperfunctions