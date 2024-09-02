return {
    debug = false,
    inventory = "qb", -- "ox" for ox-inventory or "qb" for qb-inventory
    percent = 25, -- A 1 in x % for a package to spawn
    searchTime = 5000, -- How long the progress bar is
    searchLabel = 'Searching', -- Label of the progress bar
    blacklistedModels = { --All Models you dont want the script to spawn packages in
        [`caddy`] = true, -- Classed as a "automobile"
        [`forklift`] = true, -- Classed as a "automobile"
        [`blazer`] = true, -- Classed as a "automobile"
        [`mlue`] = true, -- Classed as a "automobile"
        [`mlue2`] = true, -- Classed as a "automobile"
    },
    packageProps = { -- The model of the objects that can spawn in the seat
        `prop_drug_package_02`,
        `ch_prop_ch_bag_01a`,
        `tr_prop_tr_bag_clothing_01a`,
        `h4_prop_h4_cash_bag_01a`,
        `sf_prop_sf_laptop_01a`,
        `xm3_prop_xm3_backpack_01a`,
    },
    rewardItems = { --Items gotten after searching the package
        {
            item = 'money',
            minAmount = 1,
            maxAmount = 1000
        },
        {
            item = 'weapon_pistol',
            minAmount = 1,
            maxAmount = 1
        },
        {
            item = 'cola',
            minAmount = 1,
            maxAmount = 10
        },
    }
}