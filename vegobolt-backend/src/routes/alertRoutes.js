const express = require("express");
const router = express.Router();

const mockAlerts = [
  {
    title: "Tank Full",
    machine: "VB-0001",
    location: "Barangay 171",
    time: "2024-10-19T09:32:00Z",
    status: "Critical",
  },
  {
    title: "Low Battery Warning",
    machine: "VB-0002",
    location: "Barangay 172",
    time: "2024-10-18T14:15:00Z",
    status: "Warning",
  },
  {
    title: "Maintenance Required",
    machine: "VB-0003",
    location: "Barangay 173",
    time: "2024-10-17T10:20:00Z",
    status: "Resolved",
  },
];

router.get("/", (req, res) => {
  res.json(mockAlerts);
});

module.exports = router;
