from pathlib import Path
import subprocess,sys
root=Path(__file__).resolve().parents[1]
revisions={"before":"766fc0e679059ea9fc412cb60f24b8102e5c3e5f","991":"bd6f647f3857479c3a80672d4afb79efe0ffcb11","994":"eb70edc1e48b0f1b09a0ff714314884e617a6e8e","995":"3be6e76a8a9292a487a8d1a04ae8d7611ddb3c16"}
key=sys.argv[1];sha=revisions[key]
subprocess.run(["git","checkout","--detach",sha],cwd=root,check=True)
tag=("before " if key=="before" else "PR #"+key+" ")+sha[:7]
a=root/"apps/react-native-example"
(a/"repro-native/Revision.h").write_text('#define REPRO_REVISION @"'+tag+'"\n')
(a/"android/app/src/main/java/swmansion/enriched/markdown/example/ReproRevision.kt").write_text('package swmansion.enriched.markdown.example\nobject ReproRevision {const val value="'+tag+'"}\n')
# CMake's source glob must be reevaluated when the entity table appears/disappears.
(root/"packages/react-native-enriched-markdown/android/src/main/jni/CMakeLists.txt").touch()
print(tag)
