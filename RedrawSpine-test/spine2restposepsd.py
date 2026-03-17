"""
Step 1: Export skeleton.json + rest pose PSD with a stable viewport.

This script:
1) Exports skeleton.json from a .spine project.
2) Builds a fake atlas from attachments.
3) Uses analyzer to compute the global AABB across all animations.
4) Exports rest.psd with viewport aligned to 8 * DOWNSCALE.
"""

import os
import utility
import shutil


def export_skeleton_json(spine_project_path: str, export_path: str) -> str:
    skeleton_json_path = os.path.join(utility.SPINE_PROJECT_DIR, "skeleton.json")
    
    # Check if skeleton.json already exists in SpineProject
    if os.path.exists(skeleton_json_path):
        print(f"skeleton.json already exists at {skeleton_json_path}")
        return skeleton_json_path
    
    # Try to find any .json file in SpineProject and use it as skeleton.json
    for fname in os.listdir(utility.SPINE_PROJECT_DIR):
        if fname.endswith(".json") and fname != "skeleton.json":
            src = os.path.join(utility.SPINE_PROJECT_DIR, fname)
            shutil.copy(src, skeleton_json_path)
            print(f"Copied {fname} to skeleton.json")
            return skeleton_json_path
    
    # Otherwise try Spine command line export
    os.makedirs(export_path, exist_ok=True)
    export_path = os.path.abspath(export_path).replace('\\', '/')
    spine_app_dir = os.path.dirname(utility.SPINE_APP_DIR).replace('\\', '/')
    
    exportJsonString = f"""{{
"class": "export-json",
"extension": ".json",
"format": "JSON",
"prettyPrint": true,
"nonessential": false,
"cleanUp": true,
"packAtlas": null,
"packSource": "attachments",
"packTarget": "perskeleton",
"warnings": true,
"version": null,
"all": false,
"output": "{export_path}",
"input": "{spine_project_path}",
"open": false
}}"""
    jsonPath = os.path.join(utility.CACHE_DIR, "export2skeleton.json")
    open(jsonPath, "w").write(exportJsonString)
    print(f"Attempting Spine export from: {utility.SPINE_APP_DIR}")
    os.system(f'"{utility.SPINE_APP_DIR}" -e "{jsonPath}"')

    skeleton_json_path = None
    if os.path.exists(export_path):
        for path in os.listdir(export_path):
            if path.endswith(".json"):
                skeleton_json_path = os.path.join(utility.SPINE_PROJECT_DIR, "skeleton.json")
                shutil.move(os.path.join(export_path, path), skeleton_json_path)
                print(f"Exported skeleton.json successfully")
            else:
                print(path)
    
    if skeleton_json_path is None:
        raise RuntimeError(f"Failed to export skeleton.json. Please manually export from Spine to {export_path}")
    return skeleton_json_path


# 导出json
for path in os.listdir(utility.SPINE_PROJECT_DIR):
    if path.endswith(".spine"):
        spine_project_path = os.path.abspath(os.path.join(utility.SPINE_PROJECT_DIR, path)).replace('\\', '/')
        break
export_path = os.path.join(utility.CACHE_DIR, "output").replace('\\', '/')
skeleton_json_path = export_skeleton_json(spine_project_path, export_path)

# fake atlas
utility.fakeAtlas(utility.SPINE_ATTACHMENTS_DIR)

import math
import subprocess

# 计算全动画 bounding box 以决定视口大小
argv1 = os.path.abspath(skeleton_json_path).replace('\\', '/')
argv2 = os.path.abspath(os.path.join(utility.SPINE_ATTACHMENTS_DIR, "fake.atlas")).replace('\\', '/')
argv3 = "getAABB"
out, err = subprocess.Popen(args=[utility.ANALYZER_EXE, argv1, argv2, argv3], stdout=subprocess.PIPE, stderr=subprocess.PIPE).communicate()
out_str = out.decode().strip()

if out_str and "," in out_str:
    try:
        cropX, cropY, cropWidth, cropHeight = list(map(float, out_str.split(",")))
        print(f"all anim viewport from analyzer: {cropX} {cropY} {cropWidth} {cropHeight}")
    except (ValueError, TypeError):
        print(f"Analyzer output invalid: {repr(out_str)}, using fallback")
        # Fallback: assume a reasonable bounding box based on typical sprite sizes
        cropX, cropY, cropWidth, cropHeight = 0, 0, 512, 512
        print(f"Using fallback viewport: {cropX} {cropY} {cropWidth} {cropHeight}")
else:
    print(f"Analyzer returned empty output, using fallback")
    # Fallback: assume a reasonable bounding box based on typical sprite sizes
    cropX, cropY, cropWidth, cropHeight = 0, 0, 512, 512
    print(f"Using fallback viewport: {cropX} {cropY} {cropWidth} {cropHeight}")
cropX = math.floor(cropX)
cropY = math.floor(cropY)
cropWidth = math.ceil(cropWidth)
cropHeight = math.ceil(cropHeight)

# 将视口调整为8*utility.downScale的倍数，再以此导出psd。 这保证图片降采样downScale后送进StableDiffusion时宽高为8的倍数，不然sd自己也会padding到8的倍数
import json

dw = cropWidth / utility.DOWNSCALE
dh = cropHeight / utility.DOWNSCALE
if not (dw % 8 == 0):
    newcropWidth = int((dw // 8 + 1) * 8 * utility.DOWNSCALE)
    cropX = cropX - (newcropWidth - cropWidth) // 2
    cropWidth = newcropWidth
if not (dh % 8 == 0):
    newcropHeight = int((dh // 8 + 1) * 8 * utility.DOWNSCALE)
    cropY = cropY - (newcropHeight - cropHeight) // 2
    cropHeight = newcropHeight

os.makedirs(utility.PSD_DIR, exist_ok=True)
open(os.path.join(utility.PSD_DIR, "meta.json"), 'w+').write(json.dumps({"viewPort": (cropX, cropY, cropWidth, cropHeight)}))
psdPath = os.path.abspath(os.path.join(utility.PSD_DIR, "rest.psd")).replace('\\', '/')

exportJsonString = f"""{{
"class": "com.esotericsoftware.spine.editor.export.ExportSettings$ExportPsd",
"exportType": "current",
"skeletonType": "single",
"skeleton": "leidian",
"animationType": "current",
"animation": null,
"skinType": "current",
"skinNone": false,
"skin": null,
"maxBounds": false,
"renderImages": true,
"renderBones": false,
"renderOthers": false,
"scale": 100,
"fitWidth": 0,
"fitHeight": 0,
"enlarge": false,
"background": null,
"lastFrame": false,
"cropWidth": {cropWidth},
"cropHeight": {cropHeight},
"rangeStart": -1,
"rangeEnd": -1,
"outputType": "layers",
"encoding": "RLE",
"compression": 6,
"pad": false,
"msaa": 4,
"smoothing": 8,
"renderSelection": false,
"cropX": {cropX},
"cropY": {cropY},
"output": "{psdPath}",
"input": "{spine_project_path}"
}}"""

jsonPath = os.path.join(utility.CACHE_DIR, "export2psd.json")
open(jsonPath, "w").write(exportJsonString)

print(f"PSD export config written to: {jsonPath}")
print(f"Please manually export from Spine using: File > Export > {jsonPath}")
print(f"Or run: {utility.SPINE_APP_DIR} -e {jsonPath}")

# Don't fail if PSD export fails - we can continue with manually prepared attachments
try:
    os.system(f'"{utility.SPINE_APP_DIR}" -e "{jsonPath}"')
except Exception as e:
    print(f"Note: Spine CLI export failed (this is OK if attachments are already prepared): {e}")


# 手动去PSD中用PS2Spine脚本导出slots
