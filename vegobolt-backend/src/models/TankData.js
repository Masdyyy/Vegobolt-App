const mongoose = require("mongoose");

const tankSchema = new mongoose.Schema({
  status: { type: String, required: true }, // "Full" | "Low" | "Normal"
  level: { type: Number, required: true }, // percentage
}, { timestamps: true });

module.exports = mongoose.model("Tank", tankSchema);
