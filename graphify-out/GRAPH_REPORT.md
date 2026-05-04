# Graph Report - /Users/luowei/projects/libs/LWWebContainer  (2026-05-04)

## Corpus Check
- Corpus is ~32,284 words - fits in a single context window. You may not need a graph.

## Summary
- 136 nodes · 166 edges · 10 communities detected
- Extraction: 93% EXTRACTED · 7% INFERRED · 0% AMBIGUOUS · INFERRED: 11 edges (avg confidence: 0.8)
- Token cost: 0 input · 0 output

## Community Hubs (Navigation)
- [[_COMMUNITY_Community 0|Community 0]]
- [[_COMMUNITY_Community 1|Community 1]]
- [[_COMMUNITY_Community 2|Community 2]]
- [[_COMMUNITY_Community 3|Community 3]]
- [[_COMMUNITY_Community 4|Community 4]]
- [[_COMMUNITY_Community 5|Community 5]]
- [[_COMMUNITY_Community 6|Community 6]]
- [[_COMMUNITY_Community 7|Community 7]]
- [[_COMMUNITY_Community 8|Community 8]]
- [[_COMMUNITY_Community 9|Community 9]]

## God Nodes (most connected - your core abstractions)
1. `LWWebContainerViewController` - 25 edges
2. `LWWebContainerVC` - 24 edges
3. `ExampleViewController` - 8 edges
4. `Coordinator` - 7 edges
5. `URL` - 7 edges
6. `WKWebView` - 7 edges
7. `WCAppDelegate` - 7 edges
8. `AdvancedExampleViewController` - 6 edges
9. `LWWebContainerView` - 6 edges
10. `LWWebContainerRepresentable` - 5 edges

## Surprising Connections (you probably didn't know these)
- `LWWebContainerViewController` --inherits--> `UIViewController`  [EXTRACTED]
  LWWebContainer_swift/LWWebContainerViewController.swift →   _Bridges community 2 → community 0_
- `LWWebContainerViewController` --inherits--> `WKNavigationDelegate`  [EXTRACTED]
  LWWebContainer_swift/LWWebContainerViewController.swift →   _Bridges community 3 → community 0_

## Communities (17 total, 2 thin omitted)

### Community 0 - "Community 0"
Cohesion: 0.14
Nodes (5): URL, LWWebContainerViewController, WCLog(), WKHTTPCookieStoreObserver, WKScriptMessageHandler

### Community 1 - "Community 1"
Cohesion: 0.1
Nodes (20): LWWebContainerVC, -appOpenURLString, -backAction, -backItemWithAction, -cookiesDidChangeInCookieStore, -dealloc, -loadURL, -loadURLInNewTab (+12 more)

### Community 2 - "Community 2"
Cohesion: 0.12
Nodes (7): AdvancedExampleViewController, ConfigurationExampleViewController, ExampleSwiftUIView, ExampleViewController, LWWebContainerViewController, UIViewController, View

### Community 3 - "Community 3"
Cohesion: 0.14
Nodes (9): Coordinator, LWWebContainerView, LWWebContainerViewController, LWWebContainerViewWrapper, View, NSObject, UIViewRepresentable, WKNavigationDelegate (+1 more)

### Community 4 - "Community 4"
Cohesion: 0.14
Nodes (9): Bundle, LWNavigationActionPolicy, allow, cancel, openInNewTab, LWScriptMessage, LWWebContainerConfiguration, String (+1 more)

### Community 5 - "Community 5"
Cohesion: 0.25
Nodes (7): WCAppDelegate, -applicationDidBecomeActive, -applicationDidEnterBackground, -applicationdidFinishLaunchingWithOptions, -applicationWillEnterForeground, -applicationWillResignActive, -applicationWillTerminate

### Community 6 - "Community 6"
Cohesion: 0.33
Nodes (5): LWHookConfig, -hookEventDict, UIResponder, -load, -setupWithConfiguration

### Community 9 - "Community 9"
Cohesion: 0.4
Nodes (4): MyTabBarController, -setSelectedIndex, -tabBardidSelectItem, -viewDidLoad

## Knowledge Gaps
- **36 isolated node(s):** `String`, `LWScriptMessage`, `allow`, `cancel`, `openInNewTab` (+31 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **2 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `LWWebContainerViewController` connect `Community 0` to `Community 2`, `Community 3`?**
  _High betweenness centrality (0.364) - this node is a cross-community bridge._
- **Why does `LWWebContainerVC` connect `Community 1` to `Community 0`, `Community 3`?**
  _High betweenness centrality (0.220) - this node is a cross-community bridge._
- **Are the 5 inferred relationships involving `URL` (e.g. with `.example_loadURLInContainer()` and `.example_loadURLInNewTab()`) actually correct?**
  _`URL` has 5 INFERRED edges - model-reasoned connections that need verification._
- **What connects `String`, `LWScriptMessage`, `allow` to the rest of the system?**
  _36 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `Community 0` be split into smaller, more focused modules?**
  _Cohesion score 0.14 - nodes in this community are weakly interconnected._
- **Should `Community 1` be split into smaller, more focused modules?**
  _Cohesion score 0.1 - nodes in this community are weakly interconnected._
- **Should `Community 2` be split into smaller, more focused modules?**
  _Cohesion score 0.12 - nodes in this community are weakly interconnected._