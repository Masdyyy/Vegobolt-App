const mongoose = require("mongoose");

const tankSchema = new mongoose.Schema({
  status: { type: String, required: true }, // "Full" | "Low" | "Normal"
  level: { type: Number, required: true }, // percentage
  temperature: { type: Number, default: 0 }, // temperature in Celsius
  batteryLevel: { type: Number, default: 0 }, // battery percentage (0 = no battery sensor)
  alert: { type: String, default: "normal" }, // "normal" | "overheating" | "critical"
}, { timestamps: true });

module.exports = mongoose.model("Tank", tankSchema);
