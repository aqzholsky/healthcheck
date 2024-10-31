package main

import (
	"fmt"
	"sort"
	"strings"
	"sync"
)

type hashFunc func(string) string

const MultiHashCount = 6

func ExecutePipeline(jobs ...job) {
	in := make(chan interface{})
	wg := new(sync.WaitGroup)

	for _, pipe := range jobs {
		wg.Add(1)
		out := make(chan interface{})

		go func(pipe job, in, out chan interface{}) {
			defer func() {
				wg.Done()
				close(out)

			}()
			pipe(in, out)
		}(pipe, in, out)

		in = out
	}

	wg.Wait()
}

func processHashingPipeline(in, out chan interface{}, f hashFunc) {
	wg := new(sync.WaitGroup)
	for v := range in {
		wg.Add(1)
		go func(v interface{}) {
			defer wg.Done()
			out <- f(fmt.Sprintf("%v", v))
		}(v)
	}
	wg.Wait()
}

func SingleHash(in, out chan interface{}) {
	md5Mux := new(sync.Mutex)

	processHashingPipeline(in, out, func(s string) string {
		crc32Hash := make(chan string)

		go func() {
			defer close(crc32Hash)
			crc32Hash <- DataSignerCrc32(s)
		}()

		md5Mux.Lock()
		md5Hash := DataSignerMd5(s)
		md5Mux.Unlock()
		crc32Md5Hash := DataSignerCrc32(md5Hash)

		return fmt.Sprintf("%s~%s", <-crc32Hash, crc32Md5Hash)
	})
}

func MultiHash(in, out chan interface{}) {
	processHashingPipeline(in, out, func(s string) string {
		results := make([]string, MultiHashCount)
		wg := new(sync.WaitGroup)
		mx := new(sync.Mutex)

		for th := 0; th < MultiHashCount; th++ {
			wg.Add(1)
			go func(th int) {
				defer wg.Done()

				crc32Hash := DataSignerCrc32(fmt.Sprintf("%d%s", th, s))
				mx.Lock()
				results[th] = crc32Hash
				mx.Unlock()
			}(th)
		}
		wg.Wait()

		return strings.Join(results, "")
	})
}

func CombineResults(in chan interface{}, out chan interface{}) {
	results := []string{}

	for data := range in {
		results = append(results, fmt.Sprintf("%v", data))
	}

	sort.Strings(results)
	out <- strings.Join(results, "_")
}
