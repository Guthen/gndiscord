local function Collection( tbl, key_id )
    local collection = {}

    for i, v in ipairs( tbl ) do
        collection[v.id or v[key_id].id] = v
    end

    return collection
end

return 
{
    Collection = Collection,
}