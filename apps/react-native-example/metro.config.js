const path = require('path');
const {getDefaultConfig,mergeConfig}=require('@react-native/metro-config');
const app=__dirname, root=path.resolve(app,'../..');
module.exports=mergeConfig(getDefaultConfig(app),{
 watchFolders:[root,'/Users/yashsingh/p/projects/enriched-markdown-latex'],
 resolver:{resolveRequest:(context,name,platform)=>{
  if(name==='react-native-enriched-markdown') return {type:'sourceFile',filePath:path.join(root,'packages/react-native-enriched-markdown/src/index.tsx')};
  if(name==='react'||name.startsWith('react/')||name==='react-native'||name.startsWith('react-native/')) return context.resolveRequest({...context,originModulePath:path.join(app,'index.js')},name,platform);
  return context.resolveRequest(context,name,platform);
 }},maxWorkers:2,
});
