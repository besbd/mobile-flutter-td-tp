const express = require('express');
const bodyParser = require('body-parser');
const fs = require('fs');
const path = require('path');

const app = express();
app.use(bodyParser.json());

const produitsPath = path.join(__dirname, 'data', 'produits.json');
const commandesPath = path.join(__dirname, 'data', 'commandes.json');

// Helper functions
function readJsonFile(filePath) {
    return JSON.parse(fs.readFileSync(filePath, 'utf8'));
}

function writeJsonFile(filePath, data) {
    fs.writeFileSync(filePath, JSON.stringify(data, null, 2), 'utf8');
}

// Routes Produits
app.get('/api/produits', (req, res) => {
    try {
        res.json(readJsonFile(produitsPath));
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

app.post('/api/produits', (req, res) => {
    try {
        const produits = readJsonFile(produitsPath);
        const newProduit = { id: produits.length + 1, ...req.body };
        produits.push(newProduit);
        writeJsonFile(produitsPath, produits);
        res.status(201).json(newProduit);
    } catch (error) {
        res.status(400).json({ error: error.message });
    }
});

// Routes Commandes
app.get('/api/commandes', (req, res) => {
    try {
        res.json(readJsonFile(commandesPath));
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

app.post('/api/commandes', (req, res) => {
    try {
        const commandes = readJsonFile(commandesPath);
        const produits = readJsonFile(produitsPath);
        const newCommande = {
            id: commandes.length + 1,
            date: new Date().toISOString(),
            ...req.body,
            total: req.body.produits.reduce((total, item) => {
                const p = produits.find(p => p.id === item.id);
                return total + (p.prix * item.quantite);
            }, 0)
        };
        commandes.push(newCommande);
        writeJsonFile(commandesPath, commandes);
        res.status(201).json(newCommande);
    } catch (error) {
        res.status(400).json({ error: error.message });
    }
});

const PORT = 3000;
app.listen(PORT, () => console.log(`API running on http://localhost:${PORT}`));