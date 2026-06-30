#!/usr/bin/env python3
"""Generate Orb.xcodeproj/project.pbxproj for a cumulative GOALS step."""
from __future__ import annotations

import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
MANIFEST = Path(__file__).with_name("goals_manifest.json")
OUT = ROOT / "Orb.xcodeproj" / "project.pbxproj"

# Stable IDs
PROJECT = "A00000010000000000000001"
ORB_TARGET = "A40000010000000000000001"
ORB_TESTS_TARGET = "A40000020000000000000001"
ORB_INT_TARGET = "A40000030000000000000001"
ORB_SOURCES = "A90000010000000000000001"
ORB_TESTS_SOURCES = "A90000020000000000000001"
ORB_INT_SOURCES = "A90000030000000000000001"
ORB_PRODUCT = "A50000010000000000000001"
ORB_TESTS_PRODUCT = "A50000020000000000000001"
ORB_INT_PRODUCT = "A50000030000000000000001"
ROOT_GROUP = "A70000010000000000000001"
ORB_GROUP = "A70000020000000000000001"
ORB_TESTS_GROUP = "A70000030000000000000001"
ORB_INT_GROUP = "A70000040000000000000001"
PRODUCTS_GROUP = "A70000050000000000000001"
CORE_GROUP = "A70000060000000000000001"
STORAGE_GROUP = "A70000070000000000000001"
CAPTURE_GROUP = "A70000080000000000000001"
UI_GROUP = "A70000090000000000000001"
SEARCH_GROUP = "A700000A0000000000000001"
AI_GROUP = "A700000B0000000000000001"
SERVICES_GROUP = "A700000C0000000000000001"
ORB_PROXY = "A30000010000000000000001"
ORB_INT_PROXY = "A30000020000000000000001"
ORB_DEP = "A30000030000000000000001"
ORB_INT_DEP = "A30000040000000000000001"

GROUP_FOR = {
    "Orb/Core": CORE_GROUP,
    "Orb/Storage": STORAGE_GROUP,
    "Orb/Capture": CAPTURE_GROUP,
    "Orb/UI": UI_GROUP,
    "Orb/Search": SEARCH_GROUP,
    "Orb/AI": AI_GROUP,
    "Orb/Services": SERVICES_GROUP,
    "OrbTests": ORB_TESTS_GROUP,
    "OrbIntegrationTests": ORB_INT_GROUP,
    "Orb": ORB_GROUP,
}


def file_id(path: str) -> str:
    h = 0
    for ch in path:
        h = (h * 131 + ord(ch)) % (16**12)
    return "F" + format(h, "012X")[:24]


def build_id(path: str) -> str:
    h = 0
    for ch in "build:" + path:
        h = (h * 131 + ord(ch)) % (16**12)
    return "B" + format(h, "012X")[:24]


def group_children(files: list[str]) -> dict[str, list[str]]:
    groups: dict[str, list[str]] = {
        ORB_GROUP: [],
        CORE_GROUP: [],
        STORAGE_GROUP: [],
        CAPTURE_GROUP: [],
        UI_GROUP: [],
        SEARCH_GROUP: [],
        AI_GROUP: [],
        SERVICES_GROUP: [],
        ORB_TESTS_GROUP: [],
        ORB_INT_GROUP: [],
    }
    for path in sorted(files):
        fid = file_id(path)
        if path.startswith("OrbTests/"):
            groups[ORB_TESTS_GROUP].append(fid)
        elif path.startswith("OrbIntegrationTests/"):
            groups[ORB_INT_GROUP].append(fid)
        elif path.startswith("Orb/"):
            parts = Path(path).parts
            if len(parts) >= 3 and parts[1] in {"Core", "Storage", "Capture", "UI", "Search", "AI", "Services"}:
                key = GROUP_FOR[f"Orb/{parts[1]}"]
                groups[key].append(fid)
            elif path.endswith("Info.plist"):
                groups[ORB_GROUP].append(fid)
            else:
                groups[ORB_GROUP].append(fid)
    return groups


def render_pbxproj(orb_files: list[str], test_files: list[str], int_files: list[str], targets: list[str]) -> str:
    all_swift = orb_files + test_files + int_files
    plist_files = [p for p in orb_files if p.endswith(".plist")]
    swift_orb = [p for p in orb_files if p.endswith(".swift")]

    build_files = []
    file_refs = []
    for path in all_swift + plist_files:
        name = Path(path).name
        fr = file_id(path)
        br = build_id(path)
        file_refs.append(
            f"\t\t{fr} /* {name} */ = {{isa = PBXFileReference; lastKnownFileType = {'text.plist.xml' if name.endswith('.plist') else 'sourcecode.swift'}; path = {name}; sourceTree = \"<group>\"; }};"
        )
        if path.endswith(".swift"):
            build_files.append(
                f"\t\t{br} /* {name} in Sources */ = {{isa = PBXBuildFile; fileRef = {fr} /* {name} */; }};"
            )

    groups = group_children(all_swift + plist_files)

    def children_block(gid: str, label: str, path: str | None, child_ids: list[str]) -> str:
        kids = "\n".join(f"\t\t\t\t{cid} /* {Path(all_swift[i] if i < len(all_swift) else plist_files[0]).name} */," for i, cid in enumerate(child_ids))
        # fix names
        lines = []
        lookup = {file_id(p): Path(p).name for p in all_swift + plist_files}
        for cid in child_ids:
            lines.append(f"\t\t\t\t{cid} /* {lookup[cid]} */,")
        kids = "\n".join(lines)
        path_line = f"\n\t\t\tpath = {path};" if path else ""
        return f"\t\t{gid} /* {label} */ = {{\n\t\t\tisa = PBXGroup;\n\t\t\tchildren = (\n{kids}\n\t\t\t);{path_line}\n\t\t\tsourceTree = \"<group>\";\n\t\t}};"

    orb_children = []
    lookup = {file_id(p): p for p in all_swift + plist_files}
    for cid in groups[ORB_GROUP]:
        p = lookup.get(cid, "")
        if not (p.startswith("Orb/") and len(Path(p).parts) >= 3 and Path(p).parts[1] in {"Core", "Storage", "Capture", "UI", "Search", "AI", "Services"}):
            orb_children.append(cid)
    module_groups = []
    for label, gid, sub in [
        ("Core", CORE_GROUP, "Core"),
        ("Storage", STORAGE_GROUP, "Storage"),
        ("Capture", CAPTURE_GROUP, "Capture"),
        ("UI", UI_GROUP, "UI"),
        ("Search", SEARCH_GROUP, "Search"),
        ("AI", AI_GROUP, "AI"),
        ("Services", SERVICES_GROUP, "Services"),
    ]:
        if groups[gid] or sub in {"Core", "Storage", "Capture", "UI", "Search", "AI", "Services"}:
            module_groups.append(gid)

    def render_group(gid: str, label: str, path: str | None, cids: list[str]) -> str:
        lookup_names = {file_id(p): Path(p).name for p in all_swift + plist_files}
        kids = "\n".join(f"\t\t\t\t{c} /* {lookup_names[c]} */," for c in cids)
        path_line = f"\n\t\t\tpath = {path};" if path else ""
        return (
            f"\t\t{gid} /* {label} */ = {{\n\t\t\tisa = PBXGroup;\n\t\t\tchildren = (\n{kids}\n\t\t\t);{path_line}\n\t\t\tsourceTree = \"<group>\";\n\t\t}};"
        )

    orb_group_children = module_groups + orb_children
    orb_group_inner = "\n".join(f"\t\t\t\t{g} /* {g} */," for g in orb_group_children)
    # map ids to labels
    id_labels = {
        CORE_GROUP: "Core", STORAGE_GROUP: "Storage", CAPTURE_GROUP: "Capture",
        UI_GROUP: "UI", SEARCH_GROUP: "Search", AI_GROUP: "AI", SERVICES_GROUP: "Services",
    }
    lines = []
    for g in orb_group_children:
        if g in id_labels:
            lines.append(f"\t\t\t\t{g} /* {id_labels[g]} */,")
        else:
            lines.append(f"\t\t\t\t{g} /* {lookup.get(g, Path(lookup.get(g,'')).name if False else '')} */,")
    lookup_names = {file_id(p): Path(p).name for p in all_swift + plist_files}
    orb_lines = []
    for g in orb_group_children:
        if g in id_labels:
            orb_lines.append(f"\t\t\t\t{g} /* {id_labels[g]} */,")
        else:
            orb_lines.append(f"\t\t\t\t{g} /* {lookup_names[g]} */,")

    orb_sources_entries = []
    for p in swift_orb:
        orb_sources_entries.append(f"\t\t\t\t{build_id(p)} /* {Path(p).name} in Sources */,")
    test_sources_entries = [f"\t\t\t\t{build_id(p)} /* {Path(p).name} in Sources */," for p in test_files]
    int_sources_entries = [f"\t\t\t\t{build_id(p)} /* {Path(p).name} in Sources */," for p in int_files]

    target_blocks = []
    project_targets = []
    products = [f"\t\t\t\t{ORB_PRODUCT} /* Orb.app */,"]

    if "Orb" in targets:
        project_targets.append(f"\t\t\t\t{ORB_TARGET} /* Orb */,")
        target_blocks.append(f"""
\t\t{ORB_TARGET} /* Orb */ = {{
\t\t\tisa = PBXNativeTarget;
\t\t\tbuildConfigurationList = A80000010000000000000001;
\t\t\tbuildPhases = ({ORB_SOURCES} /* Sources */, A60000010000000000000001 /* Frameworks */);
\t\t\tbuildRules = ();
\t\t\tdependencies = ();
\t\t\tname = Orb;
\t\t\tproductName = Orb;
\t\t\tproductReference = {ORB_PRODUCT};
\t\t\tproductType = "com.apple.product-type.application";
\t\t}};""")

    if "OrbTests" in targets:
        project_targets.append(f"\t\t\t\t{ORB_TESTS_TARGET} /* OrbTests */,")
        products.append(f"\t\t\t\t{ORB_TESTS_PRODUCT} /* OrbTests.xctest */,")
        target_blocks.append(f"""
\t\t{ORB_TESTS_TARGET} /* OrbTests */ = {{
\t\t\tisa = PBXNativeTarget;
\t\t\tbuildConfigurationList = A80000020000000000000001;
\t\t\tbuildPhases = ({ORB_TESTS_SOURCES} /* Sources */, A60000020000000000000001 /* Frameworks */);
\t\t\tbuildRules = ();
\t\t\tdependencies = ({ORB_DEP} /* PBXTargetDependency */);
\t\t\tname = OrbTests;
\t\t\tproductName = OrbTests;
\t\t\tproductReference = {ORB_TESTS_PRODUCT};
\t\t\tproductType = "com.apple.product-type.bundle.unit-test";
\t\t}};""")

    if "OrbIntegrationTests" in targets:
        project_targets.append(f"\t\t\t\t{ORB_INT_TARGET} /* OrbIntegrationTests */,")
        products.append(f"\t\t\t\t{ORB_INT_PRODUCT} /* OrbIntegrationTests.xctest */,")
        target_blocks.append(f"""
\t\t{ORB_INT_TARGET} /* OrbIntegrationTests */ = {{
\t\t\tisa = PBXNativeTarget;
\t\t\tbuildConfigurationList = A80000030000000000000001;
\t\t\tbuildPhases = ({ORB_INT_SOURCES} /* Sources */, A60000030000000000000001 /* Frameworks */);
\t\t\tbuildRules = ();
\t\t\tdependencies = ({ORB_INT_DEP} /* PBXTargetDependency */);
\t\t\tname = OrbIntegrationTests;
\t\t\tproductName = OrbIntegrationTests;
\t\t\tproductReference = {ORB_INT_PRODUCT};
\t\t\tproductType = "com.apple.product-type.bundle.unit-test";
\t\t}};""")

    dep_section = ""
    if "OrbTests" in targets:
        dep_section += f"""
\t\t{ORB_DEP} /* PBXTargetDependency */ = {{ isa = PBXTargetDependency; target = {ORB_TARGET}; targetProxy = {ORB_PROXY}; }};"""
    if "OrbIntegrationTests" in targets:
        dep_section += f"""
\t\t{ORB_INT_DEP} /* PBXTargetDependency */ = {{ isa = PBXTargetDependency; target = {ORB_TARGET}; targetProxy = {ORB_INT_PROXY}; }};"""

    proxy_section = ""
    if "OrbTests" in targets:
        proxy_section += f"""
\t\t{ORB_PROXY} /* PBXContainerItemProxy */ = {{ isa = PBXContainerItemProxy; containerPortal = {PROJECT}; proxyType = 1; remoteGlobalIDString = {ORB_TARGET}; remoteInfo = Orb; }};"""
    if "OrbIntegrationTests" in targets:
        proxy_section += f"""
\t\t{ORB_INT_PROXY} /* PBXContainerItemProxy */ = {{ isa = PBXContainerItemProxy; containerPortal = {PROJECT}; proxyType = 1; remoteGlobalIDString = {ORB_TARGET}; remoteInfo = Orb; }};"""

    test_configs = ""
    if "OrbTests" in targets:
        test_configs += """
\t\tA80000020000000000000001 = { isa = XCConfigurationList; buildConfigurations = (AB0000030000000000000001, AB0000030000000000000002); defaultConfigurationName = Release; };"""
    if "OrbIntegrationTests" in targets:
        test_configs += """
\t\tA80000030000000000000001 = { isa = XCConfigurationList; buildConfigurations = (AB0000040000000000000001, AB0000040000000000000002); defaultConfigurationName = Release; };"""

    test_build_settings = ""
    if "OrbTests" in targets:
        test_build_settings += """
\t\tAB0000030000000000000001 = { isa = XCBuildConfiguration; buildSettings = { BUNDLE_LOADER = "$(TEST_HOST)"; CODE_SIGN_STYLE = Automatic; GENERATE_INFOPLIST_FILE = YES; PRODUCT_BUNDLE_IDENTIFIER = dev.drawer.OrbTests; PRODUCT_NAME = "$(TARGET_NAME)"; SWIFT_VERSION = 5.0; TEST_HOST = "$(BUILT_PRODUCTS_DIR)/Orb.app/Contents/MacOS/Orb"; }; name = Debug; };
\t\tAB0000030000000000000002 = { isa = XCBuildConfiguration; buildSettings = { BUNDLE_LOADER = "$(TEST_HOST)"; CODE_SIGN_STYLE = Automatic; GENERATE_INFOPLIST_FILE = YES; PRODUCT_BUNDLE_IDENTIFIER = dev.drawer.OrbTests; PRODUCT_NAME = "$(TARGET_NAME)"; SWIFT_VERSION = 5.0; TEST_HOST = "$(BUILT_PRODUCTS_DIR)/Orb.app/Contents/MacOS/Orb"; }; name = Release; };"""
    if "OrbIntegrationTests" in targets:
        test_build_settings += """
\t\tAB0000040000000000000001 = { isa = XCBuildConfiguration; buildSettings = { BUNDLE_LOADER = "$(TEST_HOST)"; CODE_SIGN_STYLE = Automatic; GENERATE_INFOPLIST_FILE = YES; PRODUCT_BUNDLE_IDENTIFIER = dev.drawer.OrbIntegrationTests; PRODUCT_NAME = "$(TARGET_NAME)"; SWIFT_VERSION = 5.0; TEST_HOST = "$(BUILT_PRODUCTS_DIR)/Orb.app/Contents/MacOS/Orb"; }; name = Debug; };
\t\tAB0000040000000000000002 = { isa = XCBuildConfiguration; buildSettings = { BUNDLE_LOADER = "$(TEST_HOST)"; CODE_SIGN_STYLE = Automatic; GENERATE_INFOPLIST_FILE = YES; PRODUCT_BUNDLE_IDENTIFIER = dev.drawer.OrbIntegrationTests; PRODUCT_NAME = "$(TARGET_NAME)"; SWIFT_VERSION = 5.0; TEST_HOST = "$(BUILT_PRODUCTS_DIR)/Orb.app/Contents/MacOS/Orb"; }; name = Release; };"""

    return f"""// !$*UTF8*$!
{{
\tarchiveVersion = 1;
\tclasses = {{}};
\tobjectVersion = 56;
\tobjects = {{

/* Begin PBXBuildFile section */
{chr(10).join(build_files)}
/* End PBXBuildFile section */

/* Begin PBXContainerItemProxy section */{proxy_section}
/* End PBXContainerItemProxy section */

/* Begin PBXFileReference section */
{chr(10).join(file_refs)}
\t\t{ORB_PRODUCT} /* Orb.app */ = {{isa = PBXFileReference; explicitFileType = wrapper.application; includeInIndex = 0; path = Orb.app; sourceTree = BUILT_PRODUCTS_DIR; }};
\t\t{ORB_TESTS_PRODUCT} /* OrbTests.xctest */ = {{isa = PBXFileReference; explicitFileType = wrapper.cfbundle; includeInIndex = 0; path = OrbTests.xctest; sourceTree = BUILT_PRODUCTS_DIR; }};
\t\t{ORB_INT_PRODUCT} /* OrbIntegrationTests.xctest */ = {{isa = PBXFileReference; explicitFileType = wrapper.cfbundle; includeInIndex = 0; path = OrbIntegrationTests.xctest; sourceTree = BUILT_PRODUCTS_DIR; }};
/* End PBXFileReference section */

/* Begin PBXFrameworksBuildPhase section */
\t\tA60000010000000000000001 = {{ isa = PBXFrameworksBuildPhase; buildActionMask = 2147483647; files = (); runOnlyForDeploymentPostprocessing = 0; }};
\t\tA60000020000000000000001 = {{ isa = PBXFrameworksBuildPhase; buildActionMask = 2147483647; files = (); runOnlyForDeploymentPostprocessing = 0; }};
\t\tA60000030000000000000001 = {{ isa = PBXFrameworksBuildPhase; buildActionMask = 2147483647; files = (); runOnlyForDeploymentPostprocessing = 0; }};
/* End PBXFrameworksBuildPhase section */

/* Begin PBXGroup section */
\t\t{ROOT_GROUP} = {{ isa = PBXGroup; children = ({ORB_GROUP} /* Orb */, {ORB_TESTS_GROUP} /* OrbTests */, {ORB_INT_GROUP} /* OrbIntegrationTests */, {PRODUCTS_GROUP} /* Products */); sourceTree = "<group>"; }};
\t\t{ORB_GROUP} = {{ isa = PBXGroup; children = (
{chr(10).join(orb_lines)}
\t\t\t); path = Orb; sourceTree = "<group>"; }};
{render_group(CORE_GROUP, "Core", "Core", groups[CORE_GROUP])}
{render_group(STORAGE_GROUP, "Storage", "Storage", groups[STORAGE_GROUP])}
{render_group(CAPTURE_GROUP, "Capture", "Capture", groups[CAPTURE_GROUP])}
{render_group(UI_GROUP, "UI", "UI", groups[UI_GROUP])}
{render_group(SEARCH_GROUP, "Search", "Search", groups[SEARCH_GROUP])}
{render_group(AI_GROUP, "AI", "AI", groups[AI_GROUP])}
{render_group(SERVICES_GROUP, "Services", "Services", groups[SERVICES_GROUP])}
{render_group(ORB_TESTS_GROUP, "OrbTests", "OrbTests", groups[ORB_TESTS_GROUP])}
{render_group(ORB_INT_GROUP, "OrbIntegrationTests", "OrbIntegrationTests", groups[ORB_INT_GROUP])}
\t\t{PRODUCTS_GROUP} = {{ isa = PBXGroup; children = (
{chr(10).join(products)}
\t\t\t); name = Products; sourceTree = "<group>"; }};
/* End PBXGroup section */

/* Begin PBXNativeTarget section */{''.join(target_blocks)}
/* End PBXNativeTarget section */

/* Begin PBXProject section */
\t\t{PROJECT} = {{
\t\t\tisa = PBXProject;
\t\t\tbuildConfigurationList = A80000040000000000000001;
\t\t\tcompatibilityVersion = "Xcode 14.0";
\t\t\tdevelopmentRegion = en;
\t\t\thasScannedForEncodings = 0;
\t\t\tknownRegions = (en, Base);
\t\t\tmainGroup = {ROOT_GROUP};
\t\t\tproductRefGroup = {PRODUCTS_GROUP};
\t\t\tprojectDirPath = "";
\t\t\tprojectRoot = "";
\t\t\ttargets = (
{chr(10).join(project_targets)}
\t\t\t);
\t\t}};
/* End PBXProject section */

/* Begin PBXSourcesBuildPhase section */
\t\t{ORB_SOURCES} = {{ isa = PBXSourcesBuildPhase; buildActionMask = 2147483647; files = (
{chr(10).join(orb_sources_entries)}
\t\t\t); runOnlyForDeploymentPostprocessing = 0; }};
\t\t{ORB_TESTS_SOURCES} = {{ isa = PBXSourcesBuildPhase; buildActionMask = 2147483647; files = (
{chr(10).join(test_sources_entries)}
\t\t\t); runOnlyForDeploymentPostprocessing = 0; }};
\t\t{ORB_INT_SOURCES} = {{ isa = PBXSourcesBuildPhase; buildActionMask = 2147483647; files = (
{chr(10).join(int_sources_entries)}
\t\t\t); runOnlyForDeploymentPostprocessing = 0; }};
/* End PBXSourcesBuildPhase section */

/* Begin PBXTargetDependency section */{dep_section}
/* End PBXTargetDependency section */

/* Begin XCBuildConfiguration section */
\t\tAB0000010000000000000001 = {{ isa = XCBuildConfiguration; buildSettings = {{ CLANG_ENABLE_MODULES = YES; ENABLE_TESTABILITY = YES; MACOSX_DEPLOYMENT_TARGET = 14.0; SDKROOT = macosx; SWIFT_VERSION = 5.0; }}; name = Debug; }};
\t\tAB0000010000000000000002 = {{ isa = XCBuildConfiguration; buildSettings = {{ CLANG_ENABLE_MODULES = YES; MACOSX_DEPLOYMENT_TARGET = 14.0; SDKROOT = macosx; SWIFT_VERSION = 5.0; }}; name = Release; }};
\t\tAB0000020000000000000001 = {{ isa = XCBuildConfiguration; buildSettings = {{ GENERATE_INFOPLIST_FILE = NO; INFOPLIST_FILE = Orb/Info.plist; PRODUCT_BUNDLE_IDENTIFIER = dev.drawer.Orb; PRODUCT_NAME = "$(TARGET_NAME)"; SWIFT_VERSION = 5.0; }}; name = Debug; }};
\t\tAB0000020000000000000002 = {{ isa = XCBuildConfiguration; buildSettings = {{ GENERATE_INFOPLIST_FILE = NO; INFOPLIST_FILE = Orb/Info.plist; PRODUCT_BUNDLE_IDENTIFIER = dev.drawer.Orb; PRODUCT_NAME = "$(TARGET_NAME)"; SWIFT_VERSION = 5.0; }}; name = Release; }};
{test_build_settings}
/* End XCBuildConfiguration section */

/* Begin XCConfigurationList section */
\t\tA80000010000000000000001 = {{ isa = XCConfigurationList; buildConfigurations = (AB0000020000000000000001, AB0000020000000000000002); defaultConfigurationName = Release; }};
{test_configs}
\t\tA80000040000000000000001 = {{ isa = XCConfigurationList; buildConfigurations = (AB0000010000000000000001, AB0000010000000000000002); defaultConfigurationName = Release; }};
/* End XCConfigurationList section */
\t}};
\trootObject = {PROJECT};
}}
"""


def cumulative_files(step: str, manifest: dict) -> tuple[list[str], list[str], list[str], list[str]]:
    order = manifest["order"]
    idx = order.index(step)
    orb, tests, ints, other, targets = [], [], [], [], []
    for s in order[: idx + 1]:
        entry = manifest["steps"][s]
        orb.extend(entry.get("orb", []))
        tests.extend(entry.get("orbtests", []))
        ints.extend(entry.get("integration", []))
        other.extend(entry.get("other", []))
        if entry.get("targets"):
            targets = entry["targets"]
    return orb, tests, ints, other, targets


def main() -> int:
    step = sys.argv[1] if len(sys.argv) > 1 else None
    if not step:
        print("usage: generate_pbxproj.py <step>")
        return 1
    manifest = json.loads(MANIFEST.read_text())
    orb, tests, ints, other, targets = cumulative_files(step, manifest)
    OUT.write_text(render_pbxproj(orb, tests, ints, targets))
    print(f"generated pbxproj for step {step}: {len(orb)} orb, {len(tests)} tests, {len(ints)} integration")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
