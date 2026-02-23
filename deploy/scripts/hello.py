#!/usr/bin/env python3
import pandas as pd

print("=== Hello from Python with Pandas! ===")
print(f"Pandas version: {pd.__version__}")

data = {
    "language": ["Java", "Python", "Go", "Rust"],
    "score": [85, 92, 78, 88],
}
df = pd.DataFrame(data)

print(f"\nLanguage scores:\n{df.to_string(index=False)}")
print(f"\nAverage score: {df['score'].mean():.1f}")
print(f"Top language: {df.loc[df['score'].idxmax(), 'language']}")
print("=== Done ===")
