const express = require("express");
const User = require("../models/user");
const authRouter = express.Router();
const auth = require("../middleware/auth");
const jwt = require('jsonwebtoken');

authRouter.post("/api/signup", async (req, res) => {
    try{
        const {name, email, profilePic} = req.body;
        let user = await User.findOne({email});
        if(!user){
            user = new User({
                email,
                profilePic,
                name,
            });
            user = await user.save();
        }
        const token = jwt.sign({id : user._id}, "passwordKey");
        res.json({ user, token });
    }
    catch (e){
        //by default is passes error 200 if we didn't specify .statu(500) the status code in the response will be 200
        res.status(500).json({error: e.message});
    }
});

authRouter.get("/", auth, async (req, res) => {
    const user = await User.findById(req.user);
    res.json({ user, token: req.token });
});
module.exports = authRouter;