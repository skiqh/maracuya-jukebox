var Sequelize = require("sequelize");

module.exports = function (opts) {
    var sequelize = new Sequelize("jukebox", "marek", "123", {
        dialect : "sqlite",
        storage : opts.appDir + "/jukebox.db"
    });

    return sequelize;
};
