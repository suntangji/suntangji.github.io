---
title: test
date: 2017-07-17 11:45:35
tags: ["test"]
category: ["hello"]
---
test the hexo blog
<!--more-->
这里是全文

<h3 id="打印100200-之间的素数">打印100~200 之间的素数</h3>

<p>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;所谓素数是指除了1和它本身以外，不能被任何整数整除的数，例如17就是素数，因为它不能被2~16的任一整数整除。因此判断一个整数m是否是素数，只需把m被2~m-1之间的每一个整数去除，如果都不能被整除，那么m就是一个素数.</p>

<pre class="prettyprint"><code class="language-c hljs "><span class="hljs-preprocessor">#include&lt;stdio.h&gt;</span>
<span class="hljs-preprocessor">#include&lt;math.h&gt;</span>
<span class="hljs-preprocessor">#include&lt;stdlib.h&gt;</span>
<span class="hljs-keyword">int</span> main()
{
    <span class="hljs-keyword">int</span> i, n;
    <span class="hljs-keyword">for</span> (n = <span class="hljs-number">100</span>; n &lt;= <span class="hljs-number">200</span>; n++)
    {
        <span class="hljs-keyword">for</span> (i = <span class="hljs-number">2</span>; i &lt;= n - <span class="hljs-number">1</span>; i++)
        {
            <span class="hljs-keyword">if</span> (n % i == <span class="hljs-number">0</span>)
                <span class="hljs-keyword">break</span>;
        }
        <span class="hljs-keyword">if</span> (i &gt;= n)
            <span class="hljs-built_in">printf</span>(<span class="hljs-string">"%d\t"</span>, n);
    }
    system(<span class="hljs-string">"pause"</span>);
    <span class="hljs-keyword">return</span> <span class="hljs-number">0</span>;
}</code></pre>

<p>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;另外判断方法还可以简化。m不必呗2~m-1之间的每一个整数去除，只需被2~√m之间的每一个整数去除就可以了。如果m不能被2~√m间任一整数整除，m必定是素数。</p>

<pre class="prettyprint"><code class="language-c hljs "><span class="hljs-preprocessor">#include&lt;stdio.h&gt;</span>
<span class="hljs-preprocessor">#include&lt;math.h&gt;</span>
<span class="hljs-preprocessor">#include&lt;stdlib.h&gt;</span>
<span class="hljs-keyword">int</span> main()
{
    <span class="hljs-keyword">int</span> i, n, k;
    <span class="hljs-keyword">for</span> (n = <span class="hljs-number">100</span>; n &lt;= <span class="hljs-number">200</span>; n++)
    {
            k = (<span class="hljs-keyword">int</span>)<span class="hljs-built_in">sqrt</span>(n);
            <span class="hljs-keyword">for</span> (i = <span class="hljs-number">2</span>; i &lt;= k; i++)
                <span class="hljs-keyword">if</span> (n%i == <span class="hljs-number">0</span>) <span class="hljs-keyword">break</span>;
            <span class="hljs-keyword">if</span> (i&gt;k) <span class="hljs-built_in">printf</span>(<span class="hljs-string">"%d\t"</span>,n);
    }
    system(<span class="hljs-string">"pause"</span>);
    <span class="hljs-keyword">return</span> <span class="hljs-number">0</span>;
}

</code></pre>

<p>另外附上python代码</p>



<pre class="prettyprint"><code class="language-python hljs "><span class="hljs-comment"># -*- coding: utf-8 -*-</span>
<span class="hljs-keyword">import</span> math
<span class="hljs-function"><span class="hljs-keyword">def</span> <span class="hljs-title">is_prime</span><span class="hljs-params">(value)</span>:</span>
    ret = <span class="hljs-number">0</span>
    k = int (math.sqrt(value))
    <span class="hljs-keyword">for</span> i <span class="hljs-keyword">in</span> range(<span class="hljs-number">2</span>,k+<span class="hljs-number">1</span>):
        <span class="hljs-keyword">if</span> value%i ==<span class="hljs-number">0</span>:
            <span class="hljs-keyword">break</span>
        <span class="hljs-keyword">if</span> i&gt; math.sqrt(i):
            ret = <span class="hljs-number">1</span>
    <span class="hljs-keyword">return</span> ret
<span class="hljs-keyword">for</span> i <span class="hljs-keyword">in</span> range(<span class="hljs-number">100</span>,<span class="hljs-number">201</span>):
    <span class="hljs-keyword">if</span> is_prime(i) == <span class="hljs-number">1</span>:
        <span class="hljs-keyword">print</span> (<span class="hljs-string">'{0}是素数'</span>.format(i))
</code></pre>