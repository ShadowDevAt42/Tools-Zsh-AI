// Fonction pour générer un UUID v4 en JavaScript pur
function generateUUID() {
    return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
        var r = Math.random() * 16 | 0,
            v = c == 'x' ? r : (r & 0x3 | 0x8);
        return v.toString(16);
    });
}

// Parcourir tous les éléments d'entrée
for (let item of items) {
    // Vérifier si 'params' existe dans l'élément, sinon le créer
    if (!item.json.params) {
        item.json.params = {}; // Crée le champ 'params' s'il n'existe pas
    }
    
    // Si le 'sessionId' n'existe pas déjà dans 'params', en générer un
    if (!item.json.params.sessionId) {
        const sessionId = `AiLlM-${generateUUID()}`;
        item.json.params.sessionId = sessionId;
    }
    
    // Vérifier si 'chatInput' existe dans l'élément
    if (item.json.chatInput) {
        // Si 'query' n'existe pas, le créer
        if (!item.json.query) {
            item.json.query = {}; // Crée le champ 'query' s'il n'existe pas
        }
        
        // Copier le contenu de 'chatInput' dans 'query.userInput'
        item.json.query.userInput = item.json.chatInput;
        
        // Optionnel : Supprimer le champ 'chatInput' de l'élément
        delete item.json.chatInput;
        delete item.json.sessionId;
        delete item.json.action;
    }
      // Supprimer les champs indésirables
    delete item.json.headers;
    delete item.json.body;
    delete item.json.webhookUrl;
    delete item.json.executionMode;
}

// Retourner tous les éléments modifiés
return items;
