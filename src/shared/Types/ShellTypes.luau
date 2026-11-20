--!strict
-- Presentation contracts only. Never use these fixtures as country authority.
export type Metric = { label: string, value: string, detail: string, currencyMinor: number? }
export type MapNode = { id: string, name: string, kind: string, x: number, y: number, description: string }
export type MapLink = { from: string, to: string, fromPoint: {x:number,y:number}?, toPoint: {x:number,y:number}? }
export type Destination = { id: string, label: string, shortLabel: string, group: string, phase: string, description: string }
-- Runtime immutability is enforced by PreviewData's nested table.freeze calls.
export type Preview = { metrics: { Metric }, nodes: { MapNode }, links: { MapLink }, world: any? }
return {}
