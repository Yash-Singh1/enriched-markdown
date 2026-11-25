const path = require('path');
const fs = require('fs');
const dependencies = {};
for (const name of Object.keys(require('./package.json').dependencies)) {
 if (name !== 'react-native-enriched-markdown' && name !== 'react-native') dependencies[name] = { platforms: { ios: null, android: null } };
}
dependencies['react-native-enriched-markdown'] = {root:path.resolve(__dirname,'../../packages/react-native-enriched-markdown'),platforms:{ios:{},android:{}}};
module.exports={dependencies};
