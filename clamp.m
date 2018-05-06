function a = clamp(x,minV,maxV)
    a = min(max(x,minV),maxV);
end