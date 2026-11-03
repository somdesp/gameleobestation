import math, os, subprocess
from PIL import Image
from gen import logo, wordmark
W,H,FPS,DUR=1920,1080,30,6.0
BG=(8,8,15,255)
os.makedirs("frames",exist_ok=True)
def ease(t): t=max(0,min(1,t)); return 1-(1-t)**3
def seg(t,a,b): return max(0,min(1,(t-a)/(b-a)))
N=int(FPS*DUR)
for i in range(N):
    t=i/FPS
    draw=ease(seg(t,0.3,1.6))
    na=ease(seg(t,1.2,2.0))
    burst=seg(t,1.9,2.15)-seg(t,2.15,2.8)
    glow=0.6+0.9*max(0,burst) + 0.12*math.sin(t*3)*(t>3)
    scale=1+0.04*max(0,burst)
    size=int(440*scale)
    img=Image.new("RGBA",(W,H),BG)
    if draw>0:
        l=logo(size,draw,na,glow)
        img.alpha_composite(l,((W-size)//2,(H-size)//2-90))
    wa=ease(seg(t,2.2,3.2))
    if wa>0:
        sp=0.35+0.6*(1-wa)
        w=wordmark(52,sp*0.65,wa)
        img.alpha_composite(w,((W-w.width)//2,H//2+190))
    fade=1-ease(seg(t,5.2,6.0))
    if fade<1:
        img=Image.blend(Image.new("RGBA",(W,H),BG),img,fade)
    img.convert("RGB").save(f"frames/f{i:04d}.png")
print("frames", N)
