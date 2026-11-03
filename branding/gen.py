import math
from PIL import Image, ImageDraw, ImageFilter, ImageFont, ImageChops
FONT="/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf"
C1=(0,229,255); C2=(213,0,249)  # ciano -> magenta

def gradient(w,h):
    g=Image.new("RGB",(w,h))
    px=g.load()
    for x in range(w):
        for y in range(h):
            t=(x/w*0.6+y/h*0.4)
            px[x,y]=tuple(int(C1[i]+(C2[i]-C1[i])*t) for i in range(3))
    return g

_gcache={}
def grad(w,h):
    k=(w,h)
    if k not in _gcache:
        small=gradient(64,64).resize((w,h),Image.BILINEAR)
        _gcache[k]=small
    return _gcache[k]

def hex_pts(cx,cy,r):
    return [(cx+r*math.cos(math.radians(-90+60*i)), cy+r*math.sin(math.radians(-90+60*i))) for i in range(6)]

def partial_poly(pts,frac):
    pts=pts+[pts[0]]
    segs=[math.dist(pts[i],pts[i+1]) for i in range(len(pts)-1)]
    total=sum(segs); want=total*frac; out=[pts[0]]
    for i,s in enumerate(segs):
        if want>=s: out.append(pts[i+1]); want-=s
        else:
            a,b=pts[i],pts[i+1]; f=want/s
            out.append((a[0]+(b[0]-a[0])*f,a[1]+(b[1]-a[1])*f)); break
    return out

def logo(size, draw=1.0, n_alpha=1.0, glow=0.6):
    S=4; W=size*S
    mask=Image.new("L",(W,W),0); d=ImageDraw.Draw(mask)
    cx=cy=W/2; r=W*0.42; lw=int(W*0.055)
    if draw>0:
        pp=partial_poly(hex_pts(cx,cy,r),min(draw,1))
        d.line(pp,fill=255,width=lw,joint="curve")
        for p in (pp[0],pp[-1]):
            d.ellipse([p[0]-lw/2,p[1]-lw/2,p[0]+lw/2,p[1]+lw/2],fill=255)
    if n_alpha>0:
        nm=Image.new("L",(W,W),0); dn=ImageDraw.Draw(nm)
        f=ImageFont.truetype(FONT,int(W*0.50))
        dn.text((cx,cy),"G",font=f,fill=255,anchor="mm")
        mask=ImageChops.lighter(mask, nm.point(lambda v:int(v*n_alpha)))
    mask=mask.resize((size,size),Image.LANCZOS)
    col=grad(size,size).convert("RGBA"); col.putalpha(mask)
    if glow>0:
        g=col.filter(ImageFilter.GaussianBlur(size*0.04))
        ga=g.getchannel("A").point(lambda v:int(v*glow)); g.putalpha(ga)
        out=Image.alpha_composite(g,col)
    else: out=col
    return out

def wordmark(height, spacing=0.25, alpha=1.0):
    font=ImageFont.truetype(FONT,height)
    sp=height*spacing
    def run(text):
        ws=[font.getbbox(c)[2] for c in text]
        return ws, sum(ws)+sp*(len(text)-1)
    w1,t1=run("GAMELEOBE"); w2,t2=run("STATION"); gap=height*0.7
    W=int(t1+gap+t2)+4
    img=Image.new("RGBA",(W,int(height*1.3)),(0,0,0,0)); d=ImageDraw.Draw(img)
    x=0
    for c,cw in zip("GAMELEOBE",w1):
        d.text((x,0),c,font=font,fill=(235,240,255,int(255*alpha))); x+=cw+sp
    x=t1+gap
    m=Image.new("L",img.size,0); dm=ImageDraw.Draw(m)
    for c,cw in zip("STATION",w2):
        dm.text((x,0),c,font=font,fill=int(255*alpha)); x+=cw+sp
    g=grad(*img.size).convert("RGBA"); g.putalpha(m)
    return Image.alpha_composite(img,g)

if __name__=="__main__":
    import os
    os.makedirs("plymouth",exist_ok=True)
    logo(260).save("plymouth/logo.png")
    wordmark(30,0.22).save("plymouth/wordmark.png")
    tr=Image.new("RGBA",(260,4),(255,255,255,40)); tr.save("plymouth/track.png")
    b=grad(80,4).convert("RGBA"); b.save("plymouth/bar.png")
    # logo grande para papel/preview
    logo(512).save("logo.png")
    print("ok")
