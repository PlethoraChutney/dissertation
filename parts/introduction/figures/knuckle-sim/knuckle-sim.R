 l i b r a r y ( t i d y v e r s e ) 
 
 r e a d _ c s v ( ' k n u c k l e - s i m . c s v ' )   | >   
     p i v o t _ l o n g e r ( c o l s   =   c ( i d e n t ,   s i m ) ,   n a m e s _ t o   =   ' S t a t i s t i c ' ,   v a l u e s _ t o   =   ' V a l u e ' )   | >   
     m u t a t e ( 
         x   =   i f _ e l s e ( S t a t i s t i c   = =   ' i d e n t ' ,   a ,   b ) , 
         y   =   i f _ e l s e ( S t a t i s t i c   = =   ' i d e n t ' ,   b ,   a ) , 
         l a b e l _ c o l o r   =   i f _ e l s e ( V a l u e   <   5 0 ,   ' b l a c k ' ,   ' w h i t e ' ) , 
         f o r m a t t e d _ v a l u e   =   s c a l e s : : p e r c e n t ( V a l u e / 1 0 0 ) 
     )   | >   
     g g p l o t ( 
         a e s ( 
             f c t _ r e l e v e l ( x ,   ' a l p h a ' ,   ' b e t a ' ,   ' g a m m a ' ,   ' A S I C ' ) , 
             f c t _ r e l e v e l ( y ,   ' A S I C ' ,   ' g a m m a ' ,   ' b e t a ' ,   ' a l p h a ' ) , 
             f i l l   =   V a l u e 
         ) 
     )   + 
     t h e m e _ m i n i m a l ( )   + 
     t h e m e ( l e g e n d . p o s i t i o n   =   ' n o n e ' )   + 
     g e o m _ t i l e ( )   + 
     g e o m _ t e x t ( 
         a e s ( 
             l a b e l   =   f o r m a t t e d _ v a l u e , 
             c o l o r   =   l a b e l _ c o l o r 
         ) 
     )   + 
     c o o r d _ f i x e d ( )   + 
     s c a l e _ f i l l _ d i s t i l l e r ( 
         d i r e c t i o n   =   1 
     )   + 
     s c a l e _ c o l o r _ i d e n t i t y ( )   + 
     l a b s ( 
         x   =   N U L L , 
         y   =   N U L L 
     ) 
 g g s a v e ( ' s i m i l a r i t y _ g r a p h . p d f ' ,   w i d t h   =   4 ,   h e i g h t   =   4 ) 
