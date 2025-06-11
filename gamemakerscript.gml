


function init_game_object_struct(arg0)
{
    if (!is_struct(arg0))
        exit;
    
    add_keys_to_struct(arg0);
    call_struct(arg0, "_init");
}

function call_struct(arg0, arg1)
{
    if (!is_struct(arg0) || !is_string(arg1))
        exit;
    
    var __struct = arg0;
    var __prop_names = struct_get_names(__struct);
    var __prop_len = array_length(__prop_names);
    
    for (var __i = 0; __i < __prop_len; __i++)
    {
        var mkey = __prop_names[__i];
        var mitem = variable_struct_get(__struct, mkey);
        
        if (!is_struct(mitem))
            continue;
        
        if (is_undefined(variable_struct_get(mitem, arg1)))
            continue;
        
        variable_struct_get(mitem, arg1)();
    }
}

function add_keys_to_struct(arg0)
{
    if (!is_struct(arg0))
        exit;
    
    var __struct = arg0;
    var __prop_names = struct_get_names(__struct);
    var __prop_len = array_length(__prop_names);
    
    for (var __i = 0; __i < __prop_len; __i++)
    {
        var mkey = __prop_names[__i];
        var mitem = variable_struct_get(__struct, mkey);
        mitem.key = mkey;
    }
}

function struct_to_sorted_array_by(arg0, arg1, arg2 = true)
{
    if (!is_struct(arg0))
        return [];
    
    var ret_array = struct_to_array(arg0);
    sort_array_by(ret_array, arg1, arg2);
    return ret_array;
}

function sort_array_by(arg0, arg1, arg2 = true)
{
    var length = array_length(arg0);
    
    if (length == 0)
        exit;
    
    var lb_stack = [];
    var ub_stack = [];
    var stack_pos = 1;
    lb_stack[1] = 0;
    ub_stack[1] = length - 1;
    
    do
    {
        var lb = array_get(lb_stack, stack_pos);
        var ub = array_get(ub_stack, stack_pos);
        stack_pos--;
        
        do
        {
            var pivot_pos = (lb + ub) >> 1;
            var i = lb;
            var j = ub;
            var pivot = array_get(arg0, pivot_pos);
            
            do
            {
                while (sort_array_by_compare_func(array_get(arg0, i), pivot, arg1, arg2))
                    i++;
                
                while (sort_array_by_compare_func(pivot, array_get(arg0, j), arg1, arg2))
                    j--;
                
                if (i <= j)
                {
                    var temp = array_get(arg0, i);
                    array_set(arg0, i, array_get(arg0, j));
                    array_set(arg0, j, temp);
                    i++;
                    j--;
                }
            }
            until (i > j);
            
            if (i < pivot_pos)
            {
                if (i < ub)
                {
                    stack_pos++;
                    array_set(lb_stack, stack_pos, i);
                    array_set(ub_stack, stack_pos, ub);
                }
                
                ub = j;
            }
            else
            {
                if (j > lb)
                {
                    stack_pos++;
                    array_set(lb_stack, stack_pos, lb);
                    array_set(ub_stack, stack_pos, j);
                }
                
                lb = i;
            }
        }
        until (lb >= ub);
    }
    until (stack_pos == 0);
}

function sort_array_by_compare_func(arg0, arg1, arg2, arg3 = true)
{
    if (is_array(arg2))
    {
        var a_sum = 0;
        var b_sum = 0;
        var i_loop = array_length(arg2) + 1;
        var __array = arg2;
        var __prop_len = array_length(__array);
        
        for (var __i = 0; __i < __prop_len; __i++)
        {
            var mitem = __array[__i];
            var a_res = power(10000, i_loop - __i) * get_value_ext(undefined, variable_struct_get(arg0, mitem));
            var b_res = power(10000, i_loop - __i) * get_value_ext(undefined, variable_struct_get(arg1, mitem));
            a_sum += a_res;
            b_sum += b_res;
        }
        
        return arg3 ? (a_sum < b_sum) : (a_sum > b_sum);
    }
    
    return arg3 ? (get_value_ext(undefined, variable_struct_get(arg0, arg2)) < get_value_ext(undefined, variable_struct_get(arg1, arg2))) : (get_value_ext(undefined, variable_struct_get(arg0, arg2)) > get_value_ext(undefined, variable_struct_get(arg1, arg2)));
}

function get_value_ext(arg0, arg1, arg2 = undefined)
{
    if (is_undefined(arg1))
    {
        return arg1;
    }
    else if (is_bool(arg1))
    {
        return arg1;
    }
    else if (is_string(arg1))
    {
        return arg1;
    }
    else if (is_method(arg1))
    {
        if (!is_undefined(arg0) && arg0 != -1)
        {
            if (typeof(arg0) == "ref" && !instance_exists(arg0))
                return arg1(arg2);
            
            var func = method(arg0, arg1);
            return func(arg2);
        }
        
        return arg1(arg2);
    }
    else if (is_array(arg1))
    {
        var func = maybe_add_method(arg0, arg1);
        
        if (array_length(arg1) > 3)
            return func(arg1[1], arg1[2], arg1[3]);
        else if (array_length(arg1) > 2)
            return func(arg1[1], arg1[2]);
        else if (array_length(arg1) > 1)
            return func(arg1[1]);
        else
            return func();
    }
    
    return arg1;
}

function maybe_add_method(arg0, arg1)
{
    if (is_undefined(arg0))
        return arg1;
    
    if (!is_struct(arg0) && !instance_exists(arg0))
        return arg1;
    
    if (is_array(arg1) && array_length(arg1) > 0)
    {
        var array_method = arg1[0];
        
        if (!is_callable(array_method))
            return arg1;
        
        return method(arg0, array_method);
    }
    
    if (!is_method(arg1))
        return arg1;
    
    return method(arg0, arg1);
}



function struct_to_array(arg0)
{
    if (!is_struct(arg0))
        return arg0;
    
    var ret_array = [];
    var __struct = arg0;
    var __prop_names = struct_get_names(__struct);
    var __prop_len = array_length(__prop_names);
    
    for (var __i = 0; __i < __prop_len; __i++)
    {
        var mkey = __prop_names[__i];
        var mitem = variable_struct_get(__struct, mkey);
        array_push(ret_array, mitem);
    }
    
    return ret_array;

}

function __void(arg0 = undefined)
{
    return arg0;
}


function init_rarities(arg0)
{
    add_keys_to_struct(arg0);
    var rarity_array = struct_to_sorted_array_by(arg0, "level");
    var length = array_length(rarity_array);
    var __array = rarity_array;
    var __prop_len = array_length(__array);
    
    for (var __i = 0; __i < __prop_len; __i++)
    {
        var mitem = __array[__i];
        
        if (__i > 0)
            mitem.previous_rarity = rarity_array[__i - 1];
        
        if (__i < (length - 1))
            mitem.next_rarity = rarity_array[__i + 1];
    }
    
    __array = rarity_array;
    __prop_len = array_length(__array);
    
    for (var __i = 0; __i < __prop_len; __i++)
    {
        var mitem = __array[__i];
        mitem._init();
    }
    
    return rarity_array;
}

function __return_true()
{
    return true;
}


function Type_Object(arg0) constructor
{
    cache_late = false;
    cache_upgrades_array = undefined;
    name = "";
    upgrade_attributes = undefined;
    upgrade_attributes_cache = undefined;
    upgrade_cache_text = "";
    
    _init = function()
    {
        if (!cache_late)
            self.cache_upgrades();
        
        self.init();
    };
    
    init = __void;
    init_late = __void;
    can_generate = __return_true;
    
    cache_upgrades = function()
    {
        if (!is_array(self.cache_upgrades_array))
            exit;
        
        var text = [];
        var __array = self.cache_upgrades_array;
        var __prop_len = array_length(__array);
        
        for (var __i = 0; __i < __prop_len; __i++)
        {
            var mitem = __array[__i];
            var upgrade_multiplier = get_default_struct_value(mitem, "upgrade_multiplier", 1);
            var t = sprintf("%s\n%s", mitem.name, format_upgrade_text(self.get_upgrade_attributes(), upgrade_multiplier));
            array_push(text, t);
        }
        
        self.upgrade_cache_text = implode("\n\n", text);
    };
    
    get_upgrade_attributes = function()
    {
        if (is_undefined(self.upgrade_attributes_cache))
            self.refresh_upgrade_attributes();
        
        return self.upgrade_attributes_cache;
    };
    
    refresh_upgrade_attributes = function()
    {
        self.upgrade_attributes_cache = self.upgrade_attributes;
    };
    
    set_local_vars(arg0);
    self.init();
}


function Fishing_Spot_Type(arg0) : Type_Object(arg0) constructor
{
    is_special = true;
    set_local_vars(arg0);
}

function Rarity(arg0 = undefined) constructor
{
    name = "";
    index = 0;
    key = "";
    level = 1;
    min_level = 0;
    spawn_chance = 0;
    color = 16777215;
    next_rarity = undefined;
    next_rarity_type = undefined;
    previous_rarity = undefined;
    upgrade_multiplier = 1;
    
    _init = function()
    {
        self.index = self.level;
        
        
        self.upgrade_multiplier = 1 + ((self.level - 1) / 5);
        self.init();
    };
    
    init = __void;
    
    get_spawn_chance = function()
    {
        return self.spawn_chance;
    };
    
    get_name = function()
    {
        return get_value_ext(self, self.name);
    };
    
    set_local_vars(arg0);
}

function set_local_vars(arg0)
{
    if (!is_struct(arg0))
        exit;
    
    var _props_names = variable_struct_get_names(arg0);
    var i = 0;
    var len = array_length(_props_names);
    
    while (i < len)
    {
        variable_struct_set(self, _props_names[i], variable_struct_get(arg0, _props_names[i]));
        i++;
    }
}



global.fishing_spot_types = 
    {
        fast: new Fishing_Spot_Type(
        {
            name: "Fast",
            upgrade_attributes: 
            {
                fishing_wait_duration_reduction_multiplier: 0.02
            }
        }),
        glamorous: new Fishing_Spot_Type(
        {
            name: "Glamorous",
            upgrade_attributes: 
            {
                fishing_catch_credits_multiplier: 0.05
            }
        }),
        lucky: new Fishing_Spot_Type(
        {
            name: "Lucky",
            upgrade_attributes: 
            {
                fishing_catch_rarity_multiplier: 0.1
            }
        }),
        magic: new Fishing_Spot_Type(
        {
            name: "Magic",
            upgrade_attributes: 
            {
                fishing_catch_tide_crystal_chance: 0.001
            }
        }),
        regular: new Fishing_Spot_Type(
        {
            name: "Regular",
            is_special: false
        }),
        strong: new Fishing_Spot_Type(
        {
            name: "Strong",
            upgrade_attributes: 
            {
                fishing_min_fish_length_multiplier: 0.05
            }
        })
    };
    init_game_object_struct(global.fishing_spot_types);
    global.fishing_spot_types_array = struct_to_sorted_array_by(global.fishing_spot_types, "key", true);
    global.fishing_spot_types_special = [];
    __array = global.fishing_spot_types_array;
    __prop_len = array_length(__array);
    
    for (var __i = 0; __i < __prop_len; __i++)
    {
        var mitem = __array[__i];
        
        if (mitem.key == "regular")
            continue;
        
        array_push(global.fishing_spot_types_special, mitem);
    }
    
    global.fishing_spots_rarity = 
    {
        common: new Rarity(
        {
            level: 1,
            chance: 1,
            rod_count: 1,
            name: "Common",
            catch_rarities_keys: ["common", "uncommon"]
        }),
        uncommon: new Rarity(
        {
            level: 2,
            chance: 0.3,
            rod_count: 1,
            name: "Uncommon",
            catch_rarities_keys: ["common", "uncommon", "rare"]
        }),
        rare: new Rarity(
        {
            level: 3,
            chance: 0.1,
            rod_count: 2,
            name: "Rare",
            catch_rarities_keys: ["uncommon", "rare", "epic"]
        }),
        epic: new Rarity(
        {
            level: 4,
            chance: 0.05,
            rod_count: 2,
            name: "Epic",
            catch_rarities_keys: ["rare", "epic", "mythical"]
        }),
        mythical: new Rarity(
        {
            level: 5,
            chance: 0.01,
            rod_count: 2,
            name: "Mythical",
            catch_rarities_keys: ["epic", "mythical", "legendary"]
        }),
        legendary: new Rarity(
        {
            level: 6,
            chance: 0.005,
            rod_count: 3,
            name: "Legendary",
            catch_rarities_keys: ["mythical", "legendary"]
        })
    };
    global.fishing_spots_rarity_array = init_rarities(global.fishing_spots_rarity);



function array_random_item(arg0, arg1 = undefined)
{
    if (!is_array(arg0) || array_length(arg0) == 0)
        return "";
    
    if (is_undefined(arg1))
        arg1 = array_length(arg0);
    
    var r = irandom_range(0, arg1 - 1);
    return arg0[r];
}

function percent_chance(arg0)
{
    return random(100) <= arg0;
}

function get_default_struct_value(arg0, arg1, arg2 = undefined)
{
    if (!is_struct(arg0))
        return arg2;
    
    if (is_array(arg1))
        return get_default_struct_value_deep(arg0, arg1, arg2);
    
    if (variable_struct_exists(arg0, arg1))
        return variable_struct_get(arg0, arg1);
    
    return arg2;
}

function array_fill_index(arg0)
{
    var arr = [];
    
    for (var i = 0; i < arg0; i++)
        array_push(arr, i);
    
    return arr;
}


function array_random_chance_level(arg0, arg1 = 1, arg2 = 1, arg3 = 1, arg4 = true, arg5 = undefined, arg6 = undefined, arg7 = undefined, arg8 = 0, arg9 = undefined)
{
    if (!is_array(arg0))
        exit;
    
    var chance_multiplier = get_default_struct_value(arg6, "chance_multiplier", arg8);
    var shuffle = get_default_struct_value(arg6, "shuffle", true);
    var size = array_length(arg0);
    var __prop_order = array_fill_index(size);
    
    if (shuffle)
        __prop_order = array_shuffle(__prop_order);
    
    for (var __i = 0; __i < size; __i++)
    {
        var __sindex = __prop_order[__i];
        var mitem = arg0[__sindex];
        var chance = get_default_struct_value(mitem, "chance", arg1);
        
        if (!is_numeric(chance))
            chance = arg1;
        
        if (is_numeric(arg9))
            chance = arg9;
        
        chance *= (1 + chance_multiplier);
        
        if (!percent_chance(chance * 100))
            continue;
        
        var item_level = get_default_struct_value(mitem, "min_level", arg3);
        
        if (arg2 < item_level)
            continue;
        
        if (arg4 && is_struct(mitem) && is_callable(struct_get_from_hash(mitem, variable_get_hash("can_generate"))) && !mitem.can_generate(mitem))
            continue;
        
        return mitem;
    }
    
    return arg7;
}

function brut(seed, goggle){
    random_set_seed(seed + 1);
	
    var is_special = percent_chance(10);
    var type = global.fishing_spot_types.regular;
    
    if (is_special)
        type = array_random_item(global.fishing_spot_types_special);
    
    var rarity = array_random_chance_level(global.fishing_spots_rarity_array, undefined, undefined, undefined, undefined, undefined, undefined, undefined, goggle);
	
	return "\"" + rarity.name + ":" + type.name + "\"";
}


var fname = get_save_filename("json|*.json", "");
var file = file_text_open_write(fname);
file_text_write_string(file, "[\n");
for (var i = 0; i < 200000; i++) {
	file_text_write_string(file, "[" + brut(i, 0) + "," + brut(i, .2) + "," + brut(i, .4) + "," + brut(i, .6) + "," + brut(i, .8) + "," + brut(i, 1) + "],\n");
}
file_text_write_string(file, "]");
file_text_close(file);
